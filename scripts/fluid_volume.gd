extends RefCounted
# Local three-dimensional, mass-preserving particle fluid. Spatial hashing
# restricts density/pressure/viscosity calculations to nearby particles.
const RADIUS=1.15
const MAX_PARTICLES=2400
const PARTICLE_MASS=.045
const STEP=.025
var world
var particles:Array=[]
var buckets:Dictionary={}
var root:Node3D
var display:MultiMeshInstance3D
var accumulator=0.0
var injected=0.0
var transferred=0.0
var clock=0.0

func reset(w,parent:Node3D,data={}):
 world=w
 root=parent
 particles=[]
 buckets={}
 accumulator=0.0
 injected=0.0
 transferred=0.0
 clock=0.0
 if data is Dictionary:
  for row in data.get("particles",[]):
   if row is Array and row.size()>=7:
    particles.append({"p":Vector3(float(row[0]),float(row[1]),float(row[2])),"v":Vector3(float(row[3]),float(row[4]),float(row[5])),"age":float(row[6]),"density":0.0})
  injected=float(data.get("injected",0))
  transferred=float(data.get("transferred",0))
 display=MultiMeshInstance3D.new()
 parent.add_child(display)
 display.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var mesh=SphereMesh.new()
 mesh.radius=.22
 mesh.height=.44
 mesh.radial_segments=8
 mesh.rings=4
 var mat=StandardMaterial3D.new()
 mat.albedo_color=Color(.13,.55,.68,.78)
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.roughness=.21
 mesh.material=mat
 var multi=MultiMesh.new()
 multi.transform_format=MultiMesh.TRANSFORM_3D
 multi.mesh=mesh
 multi.instance_count=MAX_PARTICLES
 multi.visible_instance_count=0
 display.multimesh=multi
 render()

func export_state()->Dictionary:
 var rows=[]
 for a in particles:
  var p:Vector3=a.p
  var v:Vector3=a.v
  rows.append([p.x,p.y,p.z,v.x,v.y,v.z,float(a.age)])
 return {"particles":rows,"injected":injected,"transferred":transferred}

func mass()->float:return particles.size()*PARTICLE_MASS

func emit(p:Vector3,count:int,impulse:Vector3)->int:
 var amount=mini(count,MAX_PARTICLES-particles.size())
 var rng=RandomNumberGenerator.new()
 rng.seed=int(world.sim.seed_value)+roundi(p.x*31+p.z*17)+particles.size()
 for i in range(amount):
  var offset=Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(.3,2.0),rng.randf_range(-1.0,1.0))
  particles.append({"p":p+offset,"v":impulse+Vector3(rng.randf_range(-.4,.4),rng.randf_range(0,.4),rng.randf_range(-.4,.4)),"age":0.0,"density":0.0})
 injected+=amount*PARTICLE_MASS
 return amount

func key(p:Vector3)->Vector3i:
 return Vector3i(floori(p.x/RADIUS),floori(p.y/RADIUS),floori(p.z/RADIUS))

func rebuild_hash():
 buckets.clear()
 for i in range(particles.size()):
  var k=key(particles[i].p)
  if not buckets.has(k):buckets[k]=[]
  buckets[k].append(i)

func neighbors(p:Vector3)->Array:
 var origin=key(p)
 var result=[]
 for z in range(-1,2):
  for y in range(-1,2):
   for x in range(-1,2):
    var k=origin+Vector3i(x,y,z)
    if buckets.has(k):result.append_array(buckets[k])
 return result

func step(dt:float):
 if particles.is_empty():return
 rebuild_hash()
 var acceleration=PackedVector3Array()
 acceleration.resize(particles.size())
 for i in range(particles.size()):
  var a=particles[i]
  var density=1.0
  for j in neighbors(a.p):
   if j==i:continue
   var distance:float=a.p.distance_to(particles[j].p)
   if distance<RADIUS:density+=pow(1-distance/RADIUS,3)
  a.density=density
  acceleration[i]=Vector3(0,-9.81,0)
 # Equal and opposite pressure and viscosity terms conserve pair momentum.
 for i in range(particles.size()):
  var a=particles[i]
  for j in neighbors(a.p):
   if j<=i:continue
   var b=particles[j]
   var delta:Vector3=a.p-b.p
   var distance=delta.length()
   if distance<.001 or distance>=RADIUS:continue
   var q=1-distance/RADIUS
   var pressure=maxf(0,(float(a.density)+float(b.density))*.5-1.3)
   var force=delta/distance*minf(22.0,pressure*8.0*q*q)+(Vector3(b.v)-Vector3(a.v))*.35*q
   acceleration[i]+=force
   acceleration[j]-=force
 for i in range(particles.size()):
  var a=particles[i]
  var velocity:Vector3=(Vector3(a.v)+acceleration[i].limit_length(75)*dt).limit_length(13.0)
  var p:Vector3=Vector3(a.p)+velocity*dt
  p.x=clampf(p.x,-51,51)
  p.z=clampf(p.z,-51,51)
  var terrain=float(world.height_at(p.x,p.z))+.20
  if p.y<terrain:
   p.y=terrain
   if velocity.y<0:velocity.y*=-.17
   velocity.x*=.81
   velocity.z*=.81
  a.p=p
  a.v=velocity
  a.age=float(a.age)+dt
 for i in range(particles.size()-1,-1,-1):
  var a=particles[i]
  # Once near ground and slow, deposit exactly its volume into flood grid.
  var p:Vector3=a.p
  if float(a.age)>2.0 and (p.y<float(world.height_at(p.x,p.z))+.34 or float(a.age)>12.0) and (Vector3(a.v).length()<1.3 or float(a.age)>12.0):
   world.hydro.inject(p,PARTICLE_MASS)
   transferred+=PARTICLE_MASS
   particles.remove_at(i)

func affect_bodies(dt:float):
 if not is_instance_valid(root):return
 for batch in world.debris.batches:
  for body in batch.bodies:
   if not is_instance_valid(body):continue
   var pos:Vector3=body.global_position
   var nearby=0
   var average=Vector3.ZERO
   for i in neighbors(pos):
    if i>=particles.size():continue
    var a=particles[i]
    if pos.distance_to(a.p)<RADIUS:nearby+=1;average+=Vector3(a.v)
   var depth=float(world.hydro.at(pos))
   if nearby>0 or depth>.1:
    var velocity=average/maxi(1,nearby)
    var lift=clampf(float(nearby)*.12+depth*.25,0,1.6)
    body.apply_central_force(Vector3.UP*body.mass*9.81*lift+(velocity-body.linear_velocity)*body.mass*.8*lift)

func render():
 if not is_instance_valid(display):return
 var multi=display.multimesh
 multi.visible_instance_count=mini(MAX_PARTICLES,particles.size())
 for i in range(multi.visible_instance_count):
  var a=particles[i]
  var stretch=clampf(Vector3(a.v).length()*.035,0,.45)
  multi.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3(1+stretch,1,1+stretch)),a.p))

func tick(dt:float):
 if particles.is_empty():return
 accumulator+=minf(dt,.20)
 var steps=0
 while accumulator>=STEP and steps<8:
  step(STEP)
  accumulator-=STEP
  steps+=1
 rebuild_hash()
 affect_bodies(dt)
 render()
