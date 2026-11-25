extends RefCounted
# Visible ecology: persistent non-civilized populations with heritable traits,
# local forage pressure, survival, births and migration within walkable terrain.
var world
var root:Node3D
var life:Array=[]
var patches:Array=[]
var next_id=1
var births=0
var deaths=0
var nodes:Dictionary={}
var rng=RandomNumberGenerator.new()
const LIMIT=72

func reset(w,data={}):
 world=w
 rng.seed=int(w.sim.seed_value)+901
 life=[]
 patches=[]
 nodes.clear()
 next_id=1
 births=0
 deaths=0
 if data is Dictionary and data.has("life"):
  life=data.get("life",[])
  patches=data.get("patches",[])
  next_id=int(data.get("next_id",1))
  births=int(data.get("births",0))
  deaths=int(data.get("deaths",0))

func export_state()->Dictionary:
 return {"life":life,"patches":patches,"next_id":next_id,"births":births,"deaths":deaths}

func build(parent:Node3D):
 root=parent
 nodes.clear()
 if patches.is_empty():
  for i in range(26):
   var p=world.land_near(rng.randf_range(-43,43),rng.randf_range(-40,40))
   if p.y<world.SEA+.7 or not world.far_village(p,7):continue
   patches.append({"x":p.x,"z":p.z,"food":14.0})
  for i in range(mini(18,patches.size())):
   var p=patches[i]
   spawn(p,{"warm":rng.randf(),"size":rng.randf(),"speed":rng.randf(),"hue":rng.randf()},1)
 sync()

func spawn(p:Dictionary,traits:Dictionary,generation:int):
 if life.size()>=LIMIT:return
 var a={"id":next_id,"x":float(p.x),"z":float(p.z),"age":0,"energy":65.0,"traits":traits,"generation":generation,"target":-1}
 next_id+=1
 life.append(a)
 births+=1

func climate(p:Dictionary)->float:
 var h=float(world.height_at(float(p.x),float(p.z)))
 return clampf(.55+float(p.x)*.009-h*.035+(.15 if world.sim.season=="Estate" else -.18 if world.sim.season=="Inverno" else 0.0),0,1)

func daily():
 if life.is_empty() or patches.is_empty():return
 for p in patches:p.food=minf(20,float(p.food)+(2.0 if world.sim.weather_name=="Siccità" else 4.0))
 for a in life.duplicate():
  a.age=int(a.age)+1
  var best=-1
  var score=-INF
  for i in range(patches.size()):
   var p=patches[i]
   var distance=Vector2(float(a.x)-float(p.x),float(a.z)-float(p.z)).length()
   if distance>9:continue
   var candidate=float(p.food)-distance*.75-absf(climate(p)-float(a.traits.warm))*8
   if candidate>score:score=candidate;best=i
  if best>=0:
   a.target=best
   var p=patches[best]
   var distance=Vector2(float(a.x)-float(p.x),float(a.z)-float(p.z)).length()
   if distance<2.5:
    var amount=minf(3.0,float(p.food))
    p.food-=amount
    a.energy+=amount*4
  a.energy=clampf(float(a.energy)-5.0-absf(climate(a)-float(a.traits.warm))*5.0-float(a.traits.size)*2,0,100)
  if float(a.energy)<=0 or int(a.age)>80:
   life.erase(a)
   deaths+=1
   continue
  if int(a.age)>8 and int(a.age)%12==0 and float(a.energy)>72 and life.size()<LIMIT:
   var traits={}
   for key in a.traits:traits[key]=clampf(float(a.traits[key])+rng.randf_range(-.12,.12),0,1)
   spawn(a,traits,int(a.generation)+1)
   a.energy-=25
 sync()

func sync():
 if not is_instance_valid(root):return
 var seen={}
 for a in life:
  var id=int(a.id)
  seen[id]=true
  if nodes.has(id):continue
  var n=Node3D.new()
  root.add_child(n)
  var t:Dictionary=a.traits
  var color=Color("738968").lerp(Color("b38257"),float(t.hue))
  var size=.45+float(t.size)*.35
  world.sphere(n,color,Vector3.UP*.31,Vector3(size,.53,size*.78))
  world.sphere(n,color.lightened(.15),Vector3(0,.38,.28),Vector3(.38,.39,.38))
  for side in [-1,1]:
   world.sphere(n,Color("292f2b"),Vector3(side*.10,.44,.43),Vector3(.065,.065,.055))
   for z in [-1,1]:world.sphere(n,color.darkened(.1),Vector3(side*.18,.13,z*.16),Vector3(.15,.25,.17))
  for j in range(3):world.cone(n,color.lightened(.3),Vector3(0,.64,-.14+j*.14),.065,.16+float(t.warm)*.13,.0,5)
  n.position=world.ground(float(a.x),float(a.z))
  nodes[id]=n
 for id in nodes.keys():
  if not seen.has(id):nodes[id].queue_free();nodes.erase(id)

func tick(dt:float):
 if patches.is_empty():return
 for a in life:
  var id=int(a.id)
  if not nodes.has(id):continue
  var n:Node3D=nodes[id]
  var target=int(a.target)
  if target<0 or target>=patches.size():continue
  var p=patches[target]
  var from=Vector2(float(a.x),float(a.z))
  var to=Vector2(float(p.x),float(p.z))
  var next=from.move_toward(to,dt*(.65+float(a.traits.speed)))
  if world.height_at(next.x,next.y)>world.SEA+.4:
   a.x=next.x
   a.z=next.y
   n.position=world.ground(next.x,next.y)
   var d=to-from
   if d.length()>.1:n.rotation.y=atan2(d.x,d.y)
  else:a.target=-1

func report()->String:
 var generation=0
 for a in life:generation=maxi(generation,int(a.generation))
 return "FAUNA SELVATICA\n%d organismi · generazione %d\nNascite %d · morti %d\nTratti ereditabili: adattamento al clima, massa, velocità e colore."%[life.size(),generation,births,deaths]
