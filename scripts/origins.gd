extends RefCounted
# An optional origin scenario: genetic lineages must survive and reproduce
# before becoming the founders of the intelligent population.
var world
var active=false
var lineages:Array=[]
var completed=0
var generations=0
var root:Node3D
var nodes:Array=[]
var rng=RandomNumberGenerator.new()
func reset(w,data={}):
 world=w
 active=bool(data.get("active",false))
 lineages=data.get("lineages",[])
 completed=int(data.get("completed",0))
 generations=int(data.get("generations",0))
 rng.seed=int(w.sim.seed_value)+470
 if data.has("rng_state"):rng.state=int(data.rng_state)
func export_state()->Dictionary:return {"active":active,"lineages":lineages,"completed":completed,"generations":generations,"rng_state":str(rng.state)}
func begin():
 active=true
 completed=0
 generations=0
 lineages=[]
 for clan in range(2):
  for i in range(9):
   lineages.append({"clan":clan,"gen":1,"age":0,"energy":65.0,"genes":[rng.randf_range(.2,.45),rng.randf_range(.3,.7),rng.randf_range(.3,.7),rng.randf_range(.3,.7)]})
 for a in world.sim.people.duplicate():
  world.sim.people.erase(a)
  if world.actors.has(a.id):
   world.actors[a.id].node.hide()
   world.actors[a.id].node.queue_free()
   world.actors.erase(a.id)
   world.activity_labels.erase(a.id)
 world.sim.changes.clear()
 world.sim.total_births=0
 for clan in range(2):
  world.sim.villages[clan].houses=0
  world.sync_houses(clan)
 world.selected=-1
 draw()
func build(parent:Node3D):
 root=parent
 nodes=[]
 draw()
func draw():
 if not is_instance_valid(root):return
 for n in nodes:
  if is_instance_valid(n):n.hide();n.queue_free()
 nodes=[]
 if not active:return
 for i in range(lineages.size()):
  var a=lineages[i]
  var c:Vector3=world.centers[int(a.clan)]
  var angle=float(i)*2.39996
  var p=world.ground(c.x+cos(angle)*3,c.z+sin(angle)*3)
  var n=Node3D.new()
  root.add_child(n)
  n.position=p
  nodes.append(n)
  var g:Array=a.genes
  var tint=Color("729e88").lerp(Color("d5b975"),float(g[2]))
  var stage=mini(3,int(float(g[0])*4))
  world.sphere(n,tint,Vector3.UP*.3,Vector3(.55+stage*.14,.45+stage*.15,.6))
  if stage>=1:
   for side in [-1,1]:world.sphere(n,tint.lightened(.12),Vector3(side*.25,.18,0),Vector3(.22,.24,.44))
  if stage>=2:world.sphere(n,tint.lightened(.2),Vector3(0,.68,.18),Vector3(.40,.38,.38))
  if stage>=3:
   for side in [-1,1]:world.sphere(n,Color("233c35"),Vector3(side*.1,.73,.33),Vector3(.07,.08,.05))
func daily():
 if not active:return
 var next=[]
 var climate=.45 if world.sim.season=="Inverno" else .65
 for clan in range(2):
  var group=lineages.filter(func(a):return int(a.clan)==clan)
  var survivors=[]
  var children=[]
  for a in group:
   a.age=int(a.age)+1
   a.energy=clampf(float(a.energy)+9-absf(float(a.genes[1])-climate)*18-float(a.genes[0])*3,0,100)
   if float(a.energy)<=0 or int(a.age)>20:continue
   survivors.append(a)
   if int(a.age)%4==0 and float(a.energy)>60:
    var g:Array=a.genes.duplicate()
    for k in range(4):g[k]=clampf(float(g[k])+rng.randf_range(-.08,.11),.02,.98)
    g[0]=clampf(float(g[0])+.045,0,1)
    children.append({"clan":clan,"gen":int(a.gen)+1,"age":0,"energy":55.0,"genes":g})
    a.energy-=12
  survivors.append_array(children)
  survivors.sort_custom(func(a,b):return (float(a.energy)*.4+float(a.genes[0])*36+(1-absf(float(a.genes[1])-climate))*18+float(a.gen)*2.0)>(float(b.energy)*.4+float(b.genes[0])*36+(1-absf(float(b.genes[1])-climate))*18+float(b.gen)*2.0))
  next.append_array(survivors.slice(0,24))
 lineages=next
 var max_gen=0
 for a in lineages:max_gen=maxi(max_gen,int(a.gen))
 generations=maxi(generations,max_gen)
 if lineages.is_empty():draw();return
 var candidates=[]
 for clan in range(2):
  var eligible=lineages.filter(func(a):return int(a.clan)==clan and int(a.gen)>=5 and float(a.genes[0])>=.60)
  if eligible.size()>=2:candidates.append(eligible)
 if candidates.size()==2:
  for clan in range(2):
   for i in range(mini(8,candidates[clan].size())):
    var source=candidates[clan][i]
    var citizen=world.sim.birth(clan,[])
    if not citizen.is_empty():
     citizen.genes=source.genes.duplicate()
     citizen.gen=int(source.gen)
     citizen.age=18
     completed+=1
  active=false
  world.sim.spatial_autonomy=not world.test_mode and not world.benchmark_mode
  world.legend.log_event("Origini",-1,-1,"Le linee evolutive hanno dato origine ai primi popoli.")
  world.apply_changes()
 draw()
func report()->String:
 if active:return "ORIGINI · %d organismi · generazione %d"%[lineages.size(),generations]
 return "ORIGINI · %d fondatori evoluti"%completed
