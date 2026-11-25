extends RefCounted
# Presentation of actual events and current needs; does not fabricate outcomes.
const MAJOR=["Ribellione","Rivolta","Riconciliazione","Secessione","Invenzione","Tempio","Fede","Dissenso","Era","Scoperta","Origini","Addio","Nascita","Unione","Miracolo"]
static func event_key(row:Dictionary)->String:
 return "%s:%s:%s:%s:%s"%[row.get("day",-1),row.get("kind",""),row.get("clan",-1),row.get("person",-1),row.get("caption","")]
static func recent(w,limit:int=6)->Array:
 var out=[]
 var seen={}
 for row in w.legend.entries:
  if str(row.get("kind","")) not in MAJOR:continue
  var key=event_key(row)
  if seen.has(key):continue
  seen[key]=true
  out.append(row.duplicate())
  if out.size()>=limit:break
 return out
static func target(w,a:Dictionary,kind:String,caption:String)->Dictionary:
 var p:Vector3=w.actors[a.id].node.position
 return {"day":w.sim.day,"kind":kind,"clan":a.clan,"person":a.id,"caption":caption,"x":p.x,"z":p.z}
static func opportunity(w)->Dictionary:
 if w.origins.active:return {}
 var best={}
 var score=0.0
 for a in w.sim.people:
  if not w.actors.has(a.id):continue
  var danger=maxf(100-float(a.health),float(a.hunger)-15)
  if danger>score and (float(a.health)<65 or float(a.hunger)>80):
   score=danger
   best=target(w,a,"Bisogno reale",str(a.name)+(" è ferito o malato." if float(a.health)<65 else " ha molta fame."))
 if not best.is_empty():return best
 for a in w.sim.people:
  if not w.actors.has(a.id):continue
  if str(a.task)=="explore" and str(a.task_stage)=="In viaggio":
   return target(w,a,"Esplorazione",str(a.name)+" sta esplorando il territorio.")
 if w.sim.peace<35:
  var c:Vector3=w.centers[0]
  return {"day":w.sim.day,"kind":"Tensione","clan":0,"person":-1,"caption":"La pace è al %d%%. I due popoli sono in tensione."%int(w.sim.peace),"x":c.x,"z":c.z}
 return {}
static func successor(w,id:int)->int:
 var best=-1
 var age=-1.0
 for a in w.sim.people:
  if id in a.parents and w.actors.has(a.id) and float(a.age)>age:
   best=int(a.id)
   age=float(a.age)
 return best
static func climate(w,clan:int)->float:
 var c:Vector3=w.centers[clan]
 var temperature=.62-clampf(c.y*.018,0,.18)
 if c.x>10:temperature+=.09
 if c.z< -8:temperature-=.07
 if w.sim.season=="Inverno":temperature-=.16
 elif w.sim.season=="Estate":temperature+=.12
 if w.sim.weather_name=="Siccità":temperature+=.08
 return clampf(temperature,.22,.87)
static func fit(g:Array,temperature:float)->float:
 return clampf(1.0-absf(float(g[1])-temperature),0,1)
static func ecology_report(w)->String:
 var lines=[]
 for clan in range(2):
  var t=climate(w,clan)
  var n=0
  var total=0.0
  var forms=[0,0,0]
  for a in w.sim.people:
   if int(a.clan)!=clan:continue
   total+=fit(a.genes,t)
   n+=1
   var kind=2 if float(a.genes[3])>.69 else 1 if float(a.genes[1])>.65 else 0
   forms[kind]+=1
  lines.append("%s · adattamento medio %d%% · bipedi %d / tetrabraccia %d / quadrupedi %d"%[w.sim.CLANs_name(clan),int(100*total/maxi(1,n)),forms[0],forms[1],forms[2]])
 return "\n".join(lines)
static func apply_ecology(w):
 # Mild selective pressure, not a new species or ecosystem simulator.
 if not w.sim.spatial_autonomy or w.origins.active:return
 var temperatures=[climate(w,0),climate(w,1)]
 for a in w.sim.people:
  var mismatch=1.0-fit(a.genes,temperatures[int(a.clan)])
  if mismatch>.35:
   a.fatigue=minf(100,float(a.fatigue)+(mismatch-.35)*4.0)
   a.hunger=minf(100,float(a.hunger)+(mismatch-.35)*2.0)
