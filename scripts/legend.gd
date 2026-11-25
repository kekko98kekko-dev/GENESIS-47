extends RefCounted
# Player-facing stories use actual events and relationships; no fabricated NPCs.
const GOALS=["Incontra una creatura","Segui una vita","Aiuta una comunità","Scopri un luogo","Guarda crescere una generazione","Osserva una nuova era"]
const HELP=["Clicca su un abitante. Ogni nome appartiene a una vita reale.","Seleziona Segui nella scheda o fai doppio clic sulla creatura.","Usa Guarigione, Provviste o Pace. Il mondo ricorderà il tuo gesto.","Un esploratore deve raggiungere un luogo ancora sconosciuto.","Una famiglia deve avere un figlio. La sua storia continuerà.","Lascia che una civiltà raggiunga una nuova era tecnologica."]
var world
var entries:Array=[]
var monuments:Array=[]
var worship:Array=[]
var traditions:Array=[]
var journey=0
var milestones:Dictionary={}
var last_seen=-1
var root:Node3D
var visual_dirty=true
var last_day=-1
var pilgrims:Dictionary={}

func reset(w,data={}):
 world=w
 entries=[]
 monuments=[]
 worship=[{"love":55.0,"fear":0.0,"temple":false,"visits":0,"last":-1},{"love":55.0,"fear":0.0,"temple":false,"visits":0,"last":-1}]
 traditions=[{"kind":"Custodi della vita","memory":0,"era":0},{"kind":"Figli dell'orizzonte","memory":0,"era":0}]
 journey=0
 milestones={}
 last_seen=-1
 last_day=-1
 pilgrims={}
 visual_dirty=true
 if data is Dictionary:
  entries=data.get("entries",[])
  monuments=data.get("monuments",[])
  var saved=data.get("worship",[])
  if saved is Array and saved.size()==2:worship=saved
  saved=data.get("traditions",[])
  if saved is Array and saved.size()==2:traditions=saved
  journey=clampi(int(data.get("journey",0)),0,GOALS.size())
  milestones=data.get("milestones",{})
  for i in range(journey):milestones[str(i)]=true
  last_seen=int(data.get("last_seen",-1))
  last_day=int(data.get("last_day",-1))
  pilgrims=data.get("pilgrims",{})
  for row in pilgrims.values():row.revision=-1

func export_state()->Dictionary:
 return {"entries":entries,"monuments":monuments,"worship":worship,"traditions":traditions,"journey":journey,"milestones":milestones,"last_seen":last_seen,"last_day":last_day,"pilgrims":pilgrims}

func log_event(kind:String,clan:int,person:int,caption:String,location=Vector3.ZERO):
 entries.push_front({"day":world.sim.day,"kind":kind,"clan":clan,"person":person,"caption":caption,"x":location.x,"z":location.z})
 if entries.size()>1200:entries.pop_back()

func advance_goal(index:int):
 if index<0 or index>=GOALS.size() or milestones.has(str(index)):return
 milestones[str(index)]=true
 world.sim.energy=minf(100,float(world.sim.energy)+8)
 log_event("Traguardo",-1,-1,"Il Creatore ha completato: "+GOALS[index])
 while journey<GOALS.size() and milestones.has(str(journey)):journey+=1
 if not world.test_mode:world.notify_event("UN NUOVO CAPITOLO",GOALS[index])

func meet(id:int,followed:bool):
 if id<0:return
 var a=world.sim.find(id)
 if a.is_empty():return
 if last_seen!=id:
  last_seen=id
  if journey==0:
   log_event("Incontro",int(a.clan),id,"Hai incontrato "+str(a.name)+".")
   advance_goal(0)
 if followed:advance_goal(1)

func miracle(kind:String,clan:int,near:Array,p:Vector3):
 var good=kind in ["Guarigione","Provviste","Pace","Pioggia","Vita","Resurrezione","Foresta"]
 var harmful=kind in ["Meteorite","Tsunami","Vulcano","Carestia","Incendio","Fulmine","Terremoto","Tornado","Epidemia","Conflitto"]
 var row:Dictionary=worship[clan]
 if good:
  row.love=minf(100,float(row.love)+7)
  row.fear=maxf(0,float(row.fear)-3)
  if kind in ["Guarigione","Provviste","Pace"]:advance_goal(2)
 elif harmful:
  row.fear=minf(100,float(row.fear)+13)
  row.love=maxf(0,float(row.love)-8)
 else:row.love=minf(100,float(row.love)+2)
 traditions[clan].memory=int(traditions[clan].memory)+1
 var names=[]
 for a in near:
  if world.sim.find(int(a.id)).is_empty():continue
  names.append(str(a.name))
  if good:world.sim.remember(a,"Ho assistito a "+kind+" del Creatore.")
  elif harmful:world.sim.remember(a,"Temo il Creatore dopo "+kind+".")
 log_event("Miracolo",clan,-1,kind+" · "+str(names.size())+" testimoni"+(" — "+", ".join(names.slice(0,3)) if not names.is_empty() else ""),p)

func born(a:Dictionary,p:Vector3):
 if a.parents.is_empty():return
 var names=[]
 for id in a.parents:
  var parent=world.sim.find(int(id))
  if not parent.is_empty():names.append(str(parent.name))
 var description=str(a.name)+" nasce nella famiglia di "+(" e ".join(names) if not names.is_empty() else "una nuova generazione")+"."
 log_event("Nascita",int(a.clan),int(a.id),description,p)
 advance_goal(4)

func death(id:int,p:Vector3):
 var deceased={}
 for row in world.sim.dead:
  if int(row.id)==id:deceased=row;break
 if deceased.is_empty():return
 var clan=int(deceased.clan)
 log_event("Addio",clan,id,str(deceased.name)+" è morto: "+str(deceased.reason)+".",p)
 monuments.append({"id":id,"name":str(deceased.name),"clan":clan,"day":world.sim.day,"x":p.x,"z":p.z})
 if monuments.size()>240:monuments.pop_front()
 visual_dirty=true
 # Family and close friends already have grief; show it at their real positions.
 if not world.test_mode:
  for a in world.sim.people:
   if int(a.get("grief_until",0))>=world.sim.day+10 and str(a.get("special_memory","")).contains(str(deceased.name)) and world.actors.has(a.id):
    world.life_bubble(world.actors[a.id].node.position,"Mi manchi",Color("d6c7b7"))

func discovered(a:Dictionary,name:String,p:Vector3):
 log_event("Scoperta",int(a.clan),int(a.id),str(a.name)+" ha trovato "+name+".",p)
 advance_goal(3)

func era(clan:int):
 var v=world.sim.villages[clan]
 traditions[clan].era=int(v.era)
 log_event("Era",clan,-1,world.sim.CLANs_name(clan)+" entra in una nuova era.",world.centers[clan])
 advance_goal(5)
 visual_dirty=true

func temple_position(clan:int)->Vector3:
 var c:Vector3=world.centers[clan]
 return world.land_near(c.x+(-3.1 if clan==0 else 3.1),c.z-3.4)

func daily():
 if last_day==world.sim.day:return
 last_day=world.sim.day
 for clan in range(2):
  var v:Dictionary=world.sim.villages[clan]
  var row:Dictionary=worship[clan]
  var n=int(world.sim.count(clan))
  if n<=0:continue
  for a in world.sim.people:
   if int(a.clan)!=clan:continue
   for event in a.get("life_story",[]):
    if int(event.day)!=world.sim.day or str(event.kind) not in ["Unione","Amicizia","Vocazione"]:continue
    var position:Vector3=world.actors[a.id].node.position if world.actors.has(a.id) else world.centers[clan]
    log_event(str(event.kind),clan,int(a.id),str(a.name)+" · "+str(event.text),position)
  var identity="Pacifista" if clan==0 else "Esploratrice"
  if float(row.fear)>65:identity="Militarista"
  elif float(row.love)>75:identity="Religiosa"
  elif float(v.knowledge)>120 and int(v.tech)>=4:identity="Scientifica"
  elif world.ocean.enabled and world.ocean.industry.companies.any(func(f):return int(f.port)==clan and f.active):identity="Mercantile"
  elif float(v.food)<n*.8:identity="Nomade"
  if str(v.get("identity",""))!=identity:
   v["identity"]=identity
   log_event("Cultura",clan,-1,world.sim.CLANs_name(clan)+" sviluppa una cultura "+identity.to_lower()+".",world.centers[clan])
  var kind="Custodi della vita" if clan==0 else "Figli dell'orizzonte"
  if float(row.fear)>65:kind="Culto del timore"
  elif float(row.love)<25:kind="Liberi dal Creatore"
  elif float(row.love)>75:kind="Ordine della luce"
  elif int(v.era)>=3 and float(v.knowledge)>100:kind="Accademia delle stelle" if clan==0 else "Lega dei mercanti"
  if traditions[clan].kind!=kind:
   traditions[clan].kind=kind
   log_event("Fede",clan,-1,world.sim.CLANs_name(clan)+" diventa "+kind+".",world.centers[clan])
  if not row.temple and int(v.era)>=1 and float(v.wood)>=18 and float(row.love)>60:
   v.wood-=18
   row.temple=true
   visual_dirty=true
   log_event("Tempio",clan,-1,world.sim.CLANs_name(clan)+" costruisce un santuario.",temple_position(clan))
  if world.sim.day%12==0 and float(row.fear)>65:
   for a in world.sim.people:
    if int(a.clan)==clan and float(a.genes[0])>.65:
     a.faith=maxf(0,float(a.faith)-5)
     world.sim.adjust_trust(a,-3)
     if float(a.faith)<30 and not bool(a.get("dissident",false)):
      a["dissident"]=true
      world.sim.milestone(a,"Dissenso","Non seguirò più il Creatore per paura.")
      log_event("Dissenso",clan,int(a.id),str(a.name)+" rifiuta il culto imposto.",world.centers[clan])
 for key in pilgrims.keys():
  if world.sim.find(int(key)).is_empty():pilgrims.erase(key)
 if visual_dirty:rebuild_visuals(root)

func rebuild_visuals(parent:Node3D):
 root=parent
 if not is_instance_valid(root):return
 for child in root.get_children():
  root.remove_child(child)
  child.queue_free()
 visual_dirty=false
 for clan in range(2):
  if not worship[clan].temple:continue
  var n=Node3D.new()
  root.add_child(n)
  n.position=temple_position(clan)
  var tint=Color("79b8a6") if clan==0 else Color("d6a064")
  world.cone(n,Color("9c9481"),Vector3.UP*.16,1.38,.32,1.25,12)
  for i in range(6):
   var angle=i*TAU/6
   world.cone(n,Color("d3c6a8"),Vector3(cos(angle)*.83,1.04,sin(angle)*.83),.15,1.65,.12,7)
  world.cone(n,tint,Vector3.UP*2.05,1.24,.77,.10,8)
  world.sphere(n,Color("fff0b2"),Vector3.UP*2.56,Vector3(.25,.25,.25),.5)
  label(n,"Santuario",2.9)
 for row in monuments:
  var p=world.ground(float(row.x),float(row.z))
  if p.y<world.SEA+.1:continue
  var n=Node3D.new()
  root.add_child(n)
  n.position=p
  world.block(n,Color("8f9b94"),Vector3(0,.16,0),Vector3(.28,.32,.20))
  world.sphere(n,Color("d2cba5"),Vector3(0,.34,0),Vector3(.18,.12,.18))

func label(n:Node3D,value:String,height:float):
 var tag=Label3D.new()
 n.add_child(tag)
 tag.position.y=height
 tag.text=value
 tag.font_size=28
 tag.pixel_size=.008
 tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 tag.modulate=Color("f4e8cd")

func goal_text()->String:
 if journey<GOALS.size():return "CAPITOLO %d/%d · %s"%[journey+1,GOALS.size(),GOALS[journey]]
 if world.sim.people.is_empty():return "ETERNITÀ · Riporta la vita nel mondo"
 if world.sim.peace<40:return "ETERNITÀ · Una pace da ricostruire"
 if world.ocean.enabled and world.ocean.colonies.is_empty():return "ETERNITÀ · Oltre il mare"
 if world.sim.people.any(func(a):return float(a.health)<45):return "ETERNITÀ · Proteggi i più fragili"
 return "ETERNITÀ · La storia continua"

func report()->String:
 var lines=["LA TUA LEGGENDA",goal_text()]
 if journey<GOALS.size():lines.append(HELP[journey])
 for i in range(2):
  var row:Dictionary=worship[i]
  lines.append("\n"+world.sim.CLANs_name(i)+" · "+str(traditions[i].kind)+" · "+str(world.sim.villages[i].get("identity","In formazione")))
  lines.append("Amore %d%% · Timore %d%% · Testimonianze %d"%[int(row.love),int(row.fear),int(traditions[i].memory)])
  lines.append("Santuario: "+("costruito · %d presenze"%int(row.visits) if row.temple else "non costruito"))
 lines.append("\nSTORIA DEL MONDO")
 for row in entries.slice(0,24):lines.append("G%03d · %s\n%s"%[int(row.day),row.kind,row.caption])
 return "\n".join(lines)


# An optional ritual is a real path to a shrine, not passive mood generation.
# The citizen can abandon it to eat, rest, heal or flee.
func ritual_advance(a:Dictionary,node:Node3D,dt:float)->int:
 var key=str(int(a.id))
 var clan=int(a.clan)
 if not worship[clan].temple or bool(a.get("dissident",false)) or float(a.faith)<45 or float(a.age)<14 or float(a.hunger)>60 or float(a.fatigue)>60 or float(a.health)<60:
  pilgrims.erase(key)
  return -1
 if not pilgrims.has(key):
  if posmod(world.sim.day+int(a.id),14)!=0 or int(a.get("last_ritual",-1))==world.sim.day:return -1
  pilgrims[key]={"path":[],"index":0,"revision":-1,"remaining":2.0}
 var job:Dictionary=pilgrims[key]
 if int(job.revision)!=int(world.nav_version):
  job.path=[]
  var start:Vector2i=world.near_cell(node.position)
  var finish:Vector2i=world.near_cell(temple_position(clan))
  if world.nav_grid.region.has_point(start) and world.nav_grid.region.has_point(finish):
   for cell in world.nav_grid.get_id_path(start,finish):job.path.append([cell.x,cell.y])
  if job.path.is_empty():pilgrims.erase(key);return -1
  job.index=0
  job.revision=int(world.nav_version)
 var budget=dt*2.0
 while int(job.index)<job.path.size() and budget>0:
  var cell=job.path[int(job.index)]
  var target:Vector3=world.ground(float(cell[0]),float(cell[1]))
  var delta=Vector3(target.x-node.position.x,0,target.z-node.position.z)
  var length=delta.length()
  if length>.01:node.rotation.y=lerp_angle(node.rotation.y,atan2(delta.x,delta.z),clampf(dt*7,0,1))
  if length>budget:
   var p=node.position+delta.normalized()*budget
   node.position=world.ground(p.x,p.z)
   budget=0
  else:
   node.position=target
   budget-=length
   job.index+=1
 if int(job.index)<job.path.size():
  a.activity="Va al santuario"
  a.task_stage="In viaggio"
  return 1
 a["industry_action"]="social"
 a.activity="Prega"
 a.task_stage="In corso"
 job.remaining=float(job.remaining)-dt
 if float(job.remaining)>0:return 0
 a["last_ritual"]=world.sim.day
 worship[clan].visits=int(worship[clan].visits)+1
 a.mood=minf(100,float(a.mood)+5)
 a.stress=maxf(0,float(a.stress)-7)
 world.sim.remember(a,"Ho pregato al santuario.")
 log_event("Preghiera",clan,int(a.id),str(a.name)+" si raccoglie in preghiera.",node.position)
 if not world.test_mode:world.life_bubble(node.position,"PREGHIERA",Color("eed5a1"))
 pilgrims.erase(key)
 return 0


func genealogy(id:int)->String:
 var lines=[]
 var queue=[[id,0]]
 var seen={}
 while not queue.is_empty() and lines.size()<48:
  var row=queue.pop_front()
  var key=int(row[0])
  var depth=int(row[1])
  if key<0 or seen.has(key):continue
  seen[key]=true
  var person=world.sim.find(key)
  var alive=not person.is_empty()
  if not alive:
   for dead in world.sim.dead:
    if int(dead.id)==key:person=dead;break
  if person.is_empty():continue
  lines.append("  ".repeat(depth)+str(person.name)+" · G"+str(person.get("gen",1))+(" · in vita" if alive else " · memoria"))
  if depth<5:
   for parent in person.get("parents",[]):queue.append([int(parent),depth+1])
 return "\n".join(lines)
