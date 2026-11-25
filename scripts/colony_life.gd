extends RefCounted
# Persistent citizens, local jobs, kinship, route-dependent production.
const JOBS=["farm","gather","mine","craft","build","eat","sleep","social","heal"]
const LABELS={"farm":"Coltiva","gather":"Raccoglie legna","mine":"Estrae pietra","craft":"Fabbrica utensili","build":"Costruisce","eat":"Mangia","sleep":"Riposa","social":"Socializza","heal":"Si cura"}
var ocean
var world
var actors:Dictionary={}
var root:Node3D

func setup(owner):
 ocean=owner
 world=owner.world

func normalize(a:Dictionary,c:Dictionary,index:int):
 a["id"]=int(a.get("id",world.sim.next_id))
 world.sim.next_id=maxi(world.sim.next_id,int(a.id)+1)
 a["name"]=str(a.get("name","Colono "+str(a.id)))
 a["clan"]=int(c.clan)
 a["genes"]=a.get("genes",[.5,.5,.5,.5])
 a["age"]=float(a.get("age",20))
 a["health"]=float(a.get("health",100))
 a["hunger"]=float(a.get("hunger",20))
 a["fatigue"]=float(a.get("fatigue",20))
 a["mood"]=float(a.get("mood",70))
 a["social_need"]=float(a.get("social_need",35))
 a["coins"]=float(a.get("coins",0))
 a["parents"]=a.get("parents",[])
 a["partner"]=int(a.get("partner",-1))
 a["friend"]=int(a.get("friend",-1))
 a["last_child_day"]=int(a.get("last_child_day",-40))
 a["memories"]=a.get("memories",[])
 a["skill"]=float(a.get("skill",0))
 a["job"]=str(a.get("job",""))
 a["task"]=str(a.get("task",""))
 a["task_stage"]=str(a.get("task_stage","Decide"))
 a["target_id"]=int(a.get("target_id",-1))
 a["remaining"]=float(a.get("remaining",0))
 a["tasks_done"]=int(a.get("tasks_done",0))
 var p:Vector2=world.REGION_POINTS[int(c.region)]
 a["position"]=a.get("position",[p.x+cos(index*2.4)*1.5,p.y+sin(index*2.4)*1.5])
 a["path"]=a.get("path",[])
 a["path_index"]=int(a.get("path_index",0))
 a["home"]=int(a.get("home",index%maxi(1,int(c.houses))))

func migrate(c:Dictionary):
 if not c.get("citizens") is Array:
  var original=c.get("founders",[])
  c["citizens"]=[]
  for i in range(int(c.population)):
   var a:Dictionary=original[i].duplicate(true) if i<original.size() else {"id":world.sim.next_id,"age":18.0+float(i%15),"genes":[.5,.5,.5,.5]}
   normalize(a,c,i)
   c.citizens.append(a)
 else:
  for i in range(c.citizens.size()):normalize(c.citizens[i],c,i)
 c.population=c.citizens.size()
 if not c.has("graveyard"):c.graveyard=[]
 if not c.has("completed_tasks"):c.completed_tasks=0

func rebuild(parent:Node3D):
 actors.clear()
 root=parent
 sync()

func find(id:int)->Dictionary:
 for c in ocean.colonies:
  for a in c.citizens:
   if int(a.id)==id:return a
 return {}

func sync():
 if not is_instance_valid(root):return
 var seen={}
 for c in ocean.colonies:
  for a in c.citizens:
   var id=int(a.id)
   seen[id]=true
   if not actors.has(id):
    var n=Node3D.new()
    root.add_child(n)
    var rig:Dictionary=world.original_creature(n,a)
    rig.body.scale=Vector3.ONE*.68
    rig["node"]=n
    rig["phase"]=float(id)*.7
    rig["skeletal"]=rig.get("skeletal",{})
    var tag=Label3D.new()
    n.add_child(tag)
    tag.position.y=1.3
    tag.font_size=24
    tag.pixel_size=.007
    tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
    rig["tag"]=tag
    actors[id]=rig
   var r:Dictionary=actors[id]
   r.node.position=world.ground(float(a.position[0]),float(a.position[1]))
   r.node.scale=Vector3.ONE*clampf(.5+float(a.age)/26,.5,1)
   r.tag.text=str(a.name)+" · "+str(LABELS.get(a.task,"Decide"))
 for id in actors.keys():
  if not seen.has(id):
   actors[id].node.queue_free()
   actors.erase(id)

func local_point(c:Dictionary,job:String,a:Dictionary)->Vector3:
 var p:Vector2=world.REGION_POINTS[int(c.region)]
 var angle=float(int(a.id)%13)*TAU/13
 var offset=Vector2(cos(angle),sin(angle))
 match job:
  "farm":p+=Vector2(3,1)+offset
  "gather":p+=Vector2(-4,-1)+offset
  "mine":p+=Vector2(1,-4)+offset
  "craft":p+=Vector2(-2,2)+offset*.4
  "build":p+=Vector2(2,-2)+offset
  "eat":p+=offset*.7
  "sleep":
   var i=int(a.home)
   p+=Vector2(cos(i*2.4),sin(i*2.4))*sqrt(float(i))*1.3+offset*.65
  "social":
   var b=find(int(a.target_id))
   if not b.is_empty():p=Vector2(float(b.position[0]),float(b.position[1]))+offset*.7
  "heal":p+=Vector2(-1,1)+offset*.5
 return world.ground(p.x,p.y)

func choose(c:Dictionary,a:Dictionary):
 var n=int(c.population)
 var scores={"farm":maxf(0,12+n*3-float(c.food))*3+12,"gather":maxf(0,12-float(c.wood))*2+11,"mine":maxf(0,8-float(c.stone))*3+10,"craft":18.0 if float(c.wood)>=3 and float(c.stone)>=2 and float(c.tools)<n else 0.0,"build":30.0 if n>=int(c.houses)*3 and float(c.wood)>=12 and float(c.stone)>=5 else 0.0,"eat":float(a.hunger)*1.4 if float(c.food)>=1 else 0.0,"sleep":float(a.fatigue)*1.3,"social":float(a.social_need)*.85,"heal":(100-float(a.health))*2}
 if float(a.age)<14:
  for job in ["farm","gather","mine","craft","build"]:scores[job]=0
 if float(a.hunger)>80 and float(c.food)>=1:scores.eat+=100
 var best=""
 var value=-1.0
 for job in scores:
  var score=float(scores[job])+float(posmod(int(a.id)+int(a.tasks_done)+str(job).hash(),7))
  if score>value:value=score;best=job
 if best=="social":
  a.target_id=-1
  for b in c.citizens:
   if int(b.id)!=int(a.id):a.target_id=int(b.id);break
  if int(a.target_id)<0:best="sleep"
 var start:Vector2i=world.near_cell(world.ground(float(a.position[0]),float(a.position[1])))
 var end:Vector2i=world.near_cell(local_point(c,best,a))
 a.path=[]
 if world.nav_grid.region.has_point(start) and world.nav_grid.region.has_point(end):
  for cell in world.nav_grid.get_id_path(start,end):a.path.append([cell.x,cell.y])
 a.path_index=0
 if a.path.is_empty():
  a.task=""
  a.task_stage="In attesa"
  return
 a.task=best
 a.task_stage="In viaggio"
 a.remaining=1.8 if best in ["eat","social","heal"] else 3.5

func finish(c:Dictionary,a:Dictionary):
 var task=str(a.task)
 var ok=true
 match task:
  "farm":c.food=minf(500,float(c.food)+(3.5 if world.sim.weather_name=="Siccità" else 5.0))
  "gather":c.wood=minf(300,float(c.wood)+3.0)
  "mine":c.stone=minf(250,float(c.stone)+2.0)
  "craft":
   if float(c.wood)>=3 and float(c.stone)>=2:c.wood-=3;c.stone-=2;c.tools+=1
   else:ok=false
  "build":
   if float(c.wood)>=12 and float(c.stone)>=5 and int(c.houses)<12:c.wood-=12;c.stone-=5;c.houses+=1
   else:ok=false
  "eat":
   if float(c.food)>=1:
    c.food-=1
    a.hunger=maxf(0,float(a.hunger)-65)
    var payment=minf(float(a.coins),ocean.price(int(c.id),"food"))
    a.coins-=payment
    c.cash+=payment
   else:ok=false
  "sleep":a.fatigue=maxf(0,float(a.fatigue)-75)
  "heal":a.health=minf(100,float(a.health)+8)
  "social":
   var b=find(int(a.target_id))
   if b.is_empty():ok=false
   elif Vector2(float(a.position[0])-float(b.position[0]),float(a.position[1])-float(b.position[1])).length()>2.5:ok=false
   else:
    a.social_need=maxf(0,float(a.social_need)-50)
    b.social_need=maxf(0,float(b.social_need)-25)
    a.mood=minf(100,float(a.mood)+5)
    a.friend=int(b.id)
    b.friend=int(a.id)
    if int(a.partner)<0 and int(b.partner)<0 and float(a.age)>=18 and float(b.age)>=18 and not related(a,b) and float(a.mood)>65 and float(b.mood)>65:
     a.partner=int(b.id)
     b.partner=int(a.id)
 if ok:
  c.completed_tasks=int(c.completed_tasks)+1
  a.tasks_done=int(a.tasks_done)+1
  a.skill=minf(100,float(a.skill)+.3)
  a.memories.push_front("G%d · %s"%[world.sim.day,LABELS.get(task,task)])
  if a.memories.size()>18:a.memories.pop_back()
  if task in ["farm","gather","mine","craft","build"]:
   a.job=task
   var wage=minf(1.5,float(c.cash))
   c.cash-=wage
   a.coins+=wage
 a.task=""
 a.task_stage="Decide"
 a.path=[]
 a.path_index=0

func related(a:Dictionary,b:Dictionary)->bool:
 if a.parents.has(b.id) or b.parents.has(a.id):return true
 for p in a.parents:
  if b.parents.has(p):return true
 return false

func tick(dt:float):
 if not ocean.enabled or dt<=0:return
 for c in ocean.colonies:
  for a in c.citizens:
   a.hunger=minf(100,float(a.hunger)+dt*1.5)
   a.fatigue=minf(100,float(a.fatigue)+dt*1.0)
   a.social_need=minf(100,float(a.social_need)+dt*.7)
   if a.task=="" or (float(a.hunger)>95 and a.task!="eat" and c.food>=1):choose(c,a)
   if a.task=="":continue
   var moving=false
   var position=Vector2(float(a.position[0]),float(a.position[1]))
   var budget=dt*2.7
   while int(a.path_index)<a.path.size() and budget>0:
    var point=Vector2(float(a.path[int(a.path_index)][0]),float(a.path[int(a.path_index)][1]))
    var distance=position.distance_to(point)
    var cell=Vector2i(roundi(point.x),roundi(point.y))
    if not world.nav_grid.region.has_point(cell) or world.nav_grid.is_point_solid(cell):a.task="";break
    if distance<=budget:
     position=point
     a.path_index+=1
     budget-=distance
    else:
     position=position.move_toward(point,budget)
     budget=0
    moving=true
   a.position=[position.x,position.y]
   if a.task!="" and int(a.path_index)>=a.path.size():
    a.task_stage="In corso"
    a.remaining=float(a.remaining)-dt
    if a.remaining<=0:finish(c,a)
   var id=int(a.id)
   if actors.has(id):
    var r:Dictionary=actors[id]
    var old:Vector3=r.node.position
    var pos:Vector3=world.ground(position.x,position.y)
    var dir=pos-old
    r.node.position=pos
    if dir.length_squared()>.001:r.node.rotation.y=lerp_angle(r.node.rotation.y,atan2(dir.x,dir.z),clampf(dt*6,0,1))
    r.phase+=dt*(7 if moving else 2)
    for i in range(2):
     r.arms[i].rotation.x=sin(float(r.phase)+i*PI)*(.35 if moving else .08)
     r.legs[i].rotation.x=sin(float(r.phase)+i*PI+PI)*(.45 if moving else .04)
    world.CreatureRig.drive(r,a,moving,true,minf(dt,.2))
    r.tag.text=str(a.name)+" · "+str(LABELS.get(a.task,"Decide"))

func remove(c:Dictionary,a:Dictionary,reason:String):
 c.graveyard.push_front({"id":int(a.id),"name":str(a.name),"day":world.sim.day,"reason":reason})
 if c.graveyard.size()>300:c.graveyard.pop_back()
 c.cash+=float(a.coins)
 for b in c.citizens:
  if int(b.partner)==int(a.id):b.partner=-1;b.mood=maxf(0,float(b.mood)-18)
  if int(b.friend)==int(a.id):b.friend=-1
 c.citizens.erase(a)
 c.deaths=int(c.deaths)+1
 c.population=c.citizens.size()

func daily(c:Dictionary):
 c.age=int(c.age)+1
 for a in c.citizens.duplicate():
  a.age=float(a.age)+.22
  a.health=clampf(float(a.health)+(1 if float(a.hunger)<40 else -3 if float(a.hunger)>75 else -.3)-(1 if float(a.age)>65 else 0),0,100)
  if float(a.health)<=0 or float(a.age)>83:remove(c,a,"vecchiaia" if float(a.age)>83 else "carestia o malattia")
 for a in c.citizens.duplicate():
  var b=find(int(a.partner))
  if b.is_empty() or int(a.id)>=int(b.id) or not c.citizens.has(b):continue
  if c.citizens.size()>=mini(48,int(c.houses)*4) or float(c.food)<c.citizens.size()*3+5:continue
  if world.sim.day-int(a.last_child_day)<20 or world.sim.day-int(b.last_child_day)<20:continue
  if float(a.health)<60 or float(b.health)<60:continue
  var genes=[]
  for i in range(4):genes.append(clampf((float(a.genes[i])+float(b.genes[i]))*.5+world.sim.rng.randf_range(-.08,.08),.04,.98))
  var child={"id":world.sim.next_id,"age":0.0,"genes":genes,"parents":[int(a.id),int(b.id)],"position":a.position.duplicate(),"coins":0.0}
  normalize(child,c,c.citizens.size())
  c.citizens.append(child)
  a.last_child_day=world.sim.day
  b.last_child_day=world.sim.day
  c.births=int(c.births)+1
  c.food-=3
 c.population=c.citizens.size()
 c.prosperity=clampf(float(c.prosperity)+(1 if float(c.food)>c.population*2 else -3),0,100)

func damage(c:Dictionary,p:Vector3,radius:float,damage_amount:float)->int:
 var lost=0
 for a in c.citizens.duplicate():
  var q=Vector2(float(a.position[0]),float(a.position[1]))
  var distance=q.distance_to(Vector2(p.x,p.z))
  if distance>radius:continue
  a.health=maxf(0,float(a.health)-damage_amount*(1-.65*distance/maxf(.1,radius)))
  a.task=""
  if float(a.health)<=0:remove(c,a,"catastrofe");lost+=1
 return lost

func report(c:Dictionary)->String:
 var lines=["%s · %d attività concluse"%[c.name,int(c.completed_tasks)]]
 for a in c.citizens:
  lines.append("%s · %d anni · %s · salute %d · fame %d · %.1f monete"%[a.name,int(a.age),LABELS.get(a.task,"Decide"),int(a.health),int(a.hunger),float(a.coins)])
 return "\n".join(lines)
