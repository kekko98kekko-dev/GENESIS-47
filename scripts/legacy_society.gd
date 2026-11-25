extends RefCounted
# Politics, invention and inherited memory are consequences of real citizens.
const SYSTEMS=["Assemblea","Dinastia","Repubblica","Autocrazia","Lega libera"]
const INVENTIONS=["Reti di irrigazione","Medicina delle erbe","Osservatorio del Creatore","Officina di precisione","Archivio delle generazioni"]
const COSTS=[12,8,16,20,14]
const REGIONS=[Vector2(-73,0),Vector2(0,-73),Vector2(73,0),Vector2(0,73)]
const RELICS=["Minerale cantore","Seme della nebbia","Vetro solare","Spora ancestrale"]
var world
var societies:Array=[]
var archive:Array=[]
var sites:Array=[]
var root:Node3D
var markers:Dictionary={}
var last_day=-1

func reset(w,data={}):
 world=w
 societies=[]
 for i in range(2):
  societies.append({"system":"Assemblea","leader":-1,"legitimacy":65.0,"opposition":0.0,"term":0,"next_vote":20,"ban":false,"inventions":[],"resistance":0.0,"revolutions":0,"secession":false,"alliances":0,"last_temple":false})
 archive=data.get("archive",[])
 sites=data.get("sites",[])
 var saved=data.get("societies",[])
 if saved.size()==2:societies=saved
 last_day=int(data.get("last_day",-1))
 markers.clear()
func export_state()->Dictionary:
 return {"societies":societies,"archive":archive,"sites":sites,"last_day":last_day}
func record(kind:String,clan:int,person:int,message:String,p:Vector3):
 archive.append({"day":world.sim.day,"kind":kind,"clan":clan,"person":person,"text":message,"x":p.x,"z":p.z})
 # Deliberately keep important events across centuries, rather than daily chatter.
 world.legend.log_event(kind,clan,person,message,p)
func build(parent:Node3D):
 root=parent
 markers.clear()
 if world.vast_world and sites.is_empty():
  for i in range(REGIONS.size()):
   var q:Vector2=REGIONS[i]
   var p:Vector3=world.land_near(q.x+3,q.y+2)
   sites.append({"index":i,"x":p.x,"z":p.z,"found":false,"finder":-1,"day":-1})
 for row in sites:draw_site(row)
func draw_site(row:Dictionary):
 if not is_instance_valid(root):return
 var i=int(row.index)
 if markers.has(i):markers[i].hide();markers[i].queue_free()
 var n=Node3D.new()
 root.add_child(n)
 n.position=world.ground(float(row.x),float(row.z))
 markers[i]=n
 var tint=[Color("93bed1"),Color("82c39b"),Color("e4b96f"),Color("b58ebc")][i]
 for j in range(5):
  var a=j*TAU/5
  world.cone(n,Color("54696b"),Vector3(cos(a)*.75,.4,sin(a)*.75),.24,.8,.12,6)
 world.cone(n,tint,Vector3.UP*.65,.31,1.3,.02,6,.4 if row.found else .04)
 if row.found:
  var label=Label3D.new()
  n.add_child(label)
  label.position.y=1.6
  label.text=RELICS[i]
  label.font_size=24
  label.pixel_size=.009
  label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
func discover(a:Dictionary,p:Vector3):
 for row in sites:
  if row.found or Vector2(float(row.x)-p.x,float(row.z)-p.z).length()>2.5:continue
  row.found=true
  row.finder=int(a.id)
  row.day=world.sim.day
  var i=int(row.index)
  var v=world.sim.villages[int(a.clan)]
  match i:
   0:v.knowledge+=18
   1:v.food=minf(850,float(v.food)+36)
   2:v.wood+=18
   3:a.health=minf(100,float(a.health)+30)
  world.sim.milestone(a,"Scoperta",RELICS[i])
  record("Reliquia",int(a.clan),int(a.id),str(a.name)+" scopre "+RELICS[i]+".",p)
  draw_site(row)
  world.legend.advance_goal(3)
func electorate(clan:int)->Array:
 return world.sim.people.filter(func(a):return int(a.clan)==clan and float(a.age)>=14 and float(a.health)>35)
func choose_leader(adults:Array,system:String,previous:int)->Dictionary:
 if adults.is_empty():return {}
 var result={}
 var best=-INF
 for a in adults:
  var merit=float(a.skill)*.5+float(a.genes[0])*22+float(a.genes[1])*18+float(a.trust)*.25
  if system=="Dinastia" and a.parents.has(previous):merit+=150
  if system=="Autocrazia":merit+=float(a.health)*.35+float(a.genes[3])*30
  if system=="Lega libera":merit+=(100-float(a.faith))*.55
  if merit>best:best=merit;result=a
 return result
func elect(clan:int,system:String,reason:String):
 var row:Dictionary=societies[clan]
 var chosen=choose_leader(electorate(clan),system,int(row.leader))
 if chosen.is_empty():return
 row.system=system
 row.leader=int(chosen.id)
 row.term=int(row.term)+1
 row.next_vote=world.sim.day+30
 row.legitimacy=60.0
 world.sim.villages[clan].government=system
 world.sim.villages[clan].culture.leader=int(chosen.id)
 world.sim.milestone(chosen,"Governo",reason)
 record("Governo",clan,int(chosen.id),reason+" · "+str(chosen.name)+" · "+system,world.centers[clan])
func invent(clan:int,a:Dictionary,index:int)->bool:
 var row:Dictionary=societies[clan]
 var v:Dictionary=world.sim.villages[clan]
 if index<0 or index>=INVENTIONS.size() or row.inventions.has(index) or float(v.wood)<COSTS[index]:return false
 v.wood-=COSTS[index]
 row.inventions.append(index)
 match index:
  0:v.bonuses[0]=mini(12,int(v.bonuses[0])+1)
  1:v.bonuses[2]=mini(12,int(v.bonuses[2])+1)
  2:row.resistance=minf(.35,float(row.resistance)+.15)
  3:v.bonuses[1]=mini(12,int(v.bonuses[1])+1)
  4:v.culture.heritage=mini(100,int(v.culture.heritage)+12)
 world.sim.milestone(a,"Invenzione",INVENTIONS[index])
 record("Invenzione",clan,int(a.id),str(a.name)+" inventa "+INVENTIONS[index]+".",world.centers[clan])
 return true
func daily():
 if last_day==world.sim.day:return
 last_day=world.sim.day
 for clan in range(2):
  var adults=electorate(clan)
  if adults.is_empty():continue
  var row:Dictionary=societies[clan]
  var v:Dictionary=world.sim.villages[clan]
  var faith=0.0
  var discontent=0.0
  var dissidents=0
  for a in adults:
   faith+=float(a.faith)
   discontent+=(100-float(a.mood))*.45+float(a.hunger)*.25+float(a.stress)*.30
   if bool(a.get("dissident",false)):dissidents+=1
   if world.actors.has(a.id):discover(a,world.actors[a.id].node.position)
  faith/=adults.size()
  discontent/=adults.size()
  var opposition=clampf(discontent*.7+float(dissidents)/adults.size()*65+float(world.legend.worship[clan].fear)*.25,0,100)
  row.opposition=lerpf(float(row.opposition),opposition,.22)
  row.legitimacy=clampf(100-float(row.opposition),0,100)
  var leader=world.sim.find(int(row.leader))
  if leader.is_empty() or world.sim.day>=int(row.next_vote):
   var system="Dinastia" if int(v.era) in [2,3] and faith>60 else "Repubblica" if int(v.era)>=3 else "Assemblea"
   if row.ban:system="Lega libera"
   elect(clan,system,"Successione" if leader.is_empty() else "Elezione")
  if float(row.opposition)>68 and world.sim.day>=int(row.get("last_revolt",-30))+30:
   row.last_revolt=world.sim.day
   row.revolutions=int(row.revolutions)+1
   var system="Lega libera" if float(dissidents)/adults.size()>.35 else "Autocrazia"
   elect(clan,system,"Rivolta contro il governo")
   world.sim.peace=maxf(0,float(world.sim.peace)-8)
   for a in adults:
    if float(a.mood)<35:a.stress=minf(100,float(a.stress)+12)
  if not row.ban and faith<30 and float(dissidents)/adults.size()>.4:
   row.ban=true
   row.resistance=maxf(.12,float(row.resistance))
   if world.legend.worship[clan].temple:
    world.legend.worship[clan].temple=false
    world.legend.visual_dirty=true
   record("Ribellione",clan,int(row.leader),"Il culto del Creatore viene proibito; il santuario è smantellato.",world.centers[clan])
  elif row.ban and faith>65 and float(row.opposition)<35:
   row.ban=false
   record("Riconciliazione",clan,int(row.leader),"La comunità torna libera di professare il culto.",world.centers[clan])
  if world.sim.day%13==0 and int(v.era)>=1:
   for a in adults:
    if float(a.genes[0])<.65 or int(a.tasks_done)<12 or float(a.skill)<3:continue
    var index=posmod(int(a.id)+int(world.sim.day/13),INVENTIONS.size())
    if invent(clan,a,index):break
  if float(row.opposition)>72 and int(row.revolutions)>=2 and not row.secession and world.vast_world:
   var rebels=adults.filter(func(a):return bool(a.get("dissident",false)) and float(a.health)>50)
   if rebels.size()>=3 and float(v.wood)>=24:
    var target:Vector2=REGIONS[clan*2]
    var p:Vector3=world.land_near(target.x,target.y)
    v.wood-=24
    row.secession=true
    row["camp"]=[p.x,p.z]
    row["members"]=[]
    for a in rebels:
     a["separatist"]=true
     row.members.append(int(a.id))
    world.outposts.append({"x":p.x,"z":p.z,"clan":clan})
    world.rebuild_outposts()
    world.services_dirty=true
    record("Secessione",clan,int(row.leader),"Un gruppo dissidente fonda un avamposto autonomista.",p)
  if world.sim.day%40==0 and world.sim.peace>80 and float(row.opposition)<35:
   row.alliances=int(row.alliances)+1
   record("Patto",clan,int(row.leader),"Il consiglio rinnova il patto di pace.",world.centers[clan])
  # The older council may choose policies, but this regime owns leadership.
  if not world.sim.find(int(row.leader)).is_empty():
   v.government=row.system
   v.culture.leader=int(row.leader)
func report()->String:
 var lines=["EREDITÀ DEL CREATORE"]
 for i in range(2):
  var row:Dictionary=societies[i]
  lines.append("%s · %s · legittimità %d%%"%( [world.sim.CLANs_name(i),row.system,int(row.legitimacy)] ))
  lines.append("Opposizione %d%% · rivolte %d · culto %s"%[int(row.opposition),int(row.revolutions),"proibito" if row.ban else "libero"])
  if row.secession:lines.append("Avamposto autonomista · "+str(row.get("members",[]).filter(func(id):return not world.sim.find(int(id)).is_empty()).size())+" dissidenti vivi")
  var leader=world.sim.find(int(row.leader))
  if not leader.is_empty():lines.append("Guida: "+str(leader.name))
  for index in row.inventions:lines.append("Invenzione: "+INVENTIONS[int(index)])
 lines.append("Reliquie %d/%d · eventi storici %d"%[sites.filter(func(q):return q.found).size(),sites.size(),archive.size()])
 for row in archive.slice(maxi(0,archive.size()-12)):lines.append("G%d · %s"%[int(row.day),row.text])
 return "\n".join(lines)
