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
var seeded=false
const LIMIT=180
const SPECIES=["Brucatore","Saltatore","Corazzato","Predatore"]
var extinctions:Array=[]

func reset(w,data={}):
 world=w
 rng.seed=int(w.sim.seed_value)+901
 life=[]
 patches=[]
 nodes.clear()
 next_id=1
 births=0
 deaths=0
 seeded=false
 extinctions=[]
 if data is Dictionary and data.has("life"):
  life=data.get("life",[])
  patches=data.get("patches",[])
  next_id=int(data.get("next_id",1))
  births=int(data.get("births",0))
  deaths=int(data.get("deaths",0))
  seeded=bool(data.get("seeded",true))
  extinctions=data.get("extinctions",[])
  for a in life:
   a["species"]=int(a.get("species",0))
   a.traits["armor"]=float(a.traits.get("armor",.3))
  if data.has("rng_state"):rng.state=int(data.rng_state)

func export_state()->Dictionary:
 return {"life":life,"patches":patches,"next_id":next_id,"births":births,"deaths":deaths,"seeded":seeded,"rng_state":str(rng.state),"extinctions":extinctions}

func build(parent:Node3D):
 root=parent
 nodes.clear()
 if not seeded:
  seeded=true
  var extent=88.0 if world.vast_world else 43.0
  for i in range(80 if world.vast_world else 26):
   var p=world.land_near(rng.randf_range(-extent,extent),rng.randf_range(-extent,extent))
   if p.y<world.SEA+.7 or not world.far_village(p,7):continue
   patches.append({"x":p.x,"z":p.z,"food":14.0})
  for i in range(mini(40 if world.vast_world else 18,patches.size())):
   var p=patches[i]
   spawn(p,{"warm":rng.randf(),"size":rng.randf(),"speed":rng.randf(),"hue":rng.randf(),"armor":rng.randf()},1,i%SPECIES.size())
 sync()

func spawn(p:Dictionary,traits:Dictionary,generation:int,species:int=0):
 if life.size()>=LIMIT:return
 var a={"id":next_id,"x":float(p.x),"z":float(p.z),"age":0,"energy":65.0,"traits":traits,"generation":generation,"target":-1,"species":species}
 next_id+=1
 life.append(a)
 births+=1

func climate(p:Dictionary)->float:
 var h=float(world.height_at(float(p.x),float(p.z)))
 return clampf(.55+float(p.x)*.009-h*.035+(.15 if world.sim.season=="Estate" else -.18 if world.sim.season=="Inverno" else 0.0),0,1)

func daily():
 if life.is_empty() or patches.is_empty():return
 for p in patches:p.food=minf(20,float(p.food)+(2.0 if world.sim.weather_name=="Siccità" else 4.0))
 var previously=species_counts()
 for a in life.duplicate():
  if not life.has(a):continue
  a.age=int(a.age)+1
  var best=-1
  var score=-INF
  for i in range(patches.size()):
   var p=patches[i]
   var distance=Vector2(float(a.x)-float(p.x),float(a.z)-float(p.z)).length()
   if distance>9:continue
   var food_value=float(p.food) if int(a.species)!=3 else float(prey_near(p,a).size())*5
   var candidate=food_value-distance*.75-absf(climate(p)-float(a.traits.warm))*8
   if candidate>score:score=candidate;best=i
  if best>=0:
   a.target=best
   var p=patches[best]
   var distance=Vector2(float(a.x)-float(p.x),float(a.z)-float(p.z)).length()
   if distance<2.5:
    if int(a.species)==3:
     var prey=prey_near(a,a)
     if not prey.is_empty():
      var victim=prey[0]
      var chance=clampf(.65+float(a.traits.speed)*.25-float(victim.traits.armor)*.65,.05,.85)
      if rng.randf()<chance:
       life.erase(victim)
       deaths+=1
       a.energy+=25
    else:
     var amount=minf(3.0,float(p.food))
     p.food-=amount
     a.energy+=amount*4
  a.energy=clampf(float(a.energy)-4.0-absf(climate(a)-float(a.traits.warm))*5.0-float(a.traits.size)*2-float(a.traits.armor)*1.1,0,100)
  if float(a.energy)<=0 or int(a.age)>80:
   life.erase(a)
   deaths+=1
   continue
  if int(a.age)>8 and int(a.age)%12==0 and float(a.energy)>72 and life.size()<LIMIT:
   var traits={}
   for key in a.traits:traits[key]=clampf(float(a.traits[key])+rng.randf_range(-.12,.12),0,1)
   var species=int(a.species)
   if species!=3 and int(a.generation)>=4 and rng.randf()<.08:
    species=2 if float(traits.armor)>.72 else 1 if float(traits.speed)>.72 else 0
   spawn(a,traits,int(a.generation)+1,species)
   a.energy-=25
 var current=species_counts()
 for i in range(SPECIES.size()):
  if previously[i]>0 and current[i]==0:
   extinctions.append({"species":i,"day":world.sim.day})
   if not world.test_mode:world.legend.log_event("Estinzione",-1,-1,SPECIES[i]+" scompare dall’ecosistema.")
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
  if preload("res://scripts/reborn_art.gd").beast(world,n,a):
   n.position=world.ground(float(a.x),float(a.z))
   nodes[id]=n
   continue
  world.sphere(n,color,Vector3.UP*.31,Vector3(size,.53,size*.78))
  world.sphere(n,color.lightened(.15),Vector3(0,.38,.28),Vector3(.38,.39,.38))
  for side in [-1,1]:
   world.sphere(n,Color("292f2b"),Vector3(side*.10,.44,.43),Vector3(.065,.065,.055))
   for z in [-1,1]:world.sphere(n,color.darkened(.1),Vector3(side*.18,.13,z*.16),Vector3(.15,.25,.17))
  match int(a.species):
   0:
    for side in [-1,1]:world.cone(n,color.lightened(.4),Vector3(side*.17,.65,.25),.08,.25,.0,5)
   1:
    for side in [-1,1]:world.sphere(n,color.lightened(.16),Vector3(side*.13,.76,.25),Vector3(.12,.45,.12))
   2:
    world.sphere(n,color.darkened(.3),Vector3(0,.46,-.09),Vector3(size*1.1,.52,size))
    for j in range(3):world.cone(n,color.lightened(.3),Vector3(0,.69,-.14+j*.14),.08,.2+float(t.armor)*.16,0,5)
   3:
    world.sphere(n,Color("9b6a4d"),Vector3(0,.38,.46),Vector3(.28,.20,.29))
    for side in [-1,1]:world.cone(n,Color("d9c4a2"),Vector3(side*.11,.56,.30),.08,.22,0,5)
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
  var origin=Vector2(float(a.x),float(a.z))
  var to=Vector2(float(p.x),float(p.z))
  var next=origin.move_toward(to,dt*(.65+float(a.traits.speed)))
  if world.height_at(next.x,next.y)>world.SEA+.4:
   a.x=next.x
   a.z=next.y
   n.position=world.ground(next.x,next.y)
   var d=to-origin
   if d.length()>.1:n.rotation.y=atan2(d.x,d.y)
  else:a.target=-1

func report()->String:
 var generation=0
 for a in life:generation=maxi(generation,int(a.generation))
 var counts=species_counts()
 var lines=["FAUNA SELVATICA · %d organismi · generazione %d"%[life.size(),generation],"Nascite %d · morti %d · estinzioni %d"%[births,deaths,extinctions.size()]]
 for i in range(SPECIES.size()):lines.append(SPECIES[i]+": "+str(counts[i]))
 return "\n".join(lines)

func species_counts()->Array:
 var counts=[0,0,0,0]
 for a in life:counts[clampi(int(a.get("species",0)),0,3)]+=1
 return counts

func prey_near(p:Dictionary,predator:Dictionary)->Array:
 var candidates=[]
 for other in life:
  if int(other.species)==3 or other.id==predator.id:continue
  if Vector2(float(other.x)-float(p.x),float(other.z)-float(p.z)).length()<2.5:candidates.append(other)
 return candidates
