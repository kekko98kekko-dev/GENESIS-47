extends RefCounted
# Bounded native rigid-body effects; gameplay damage remains deterministic.
var world
var root:Node3D
var batches:Array=[]
const MAX_BODIES=30

func reset(w,parent:Node3D):
 world=w
 root=parent
 batches.clear()

func shape_for(size:Vector3)->BoxShape3D:
 var s=BoxShape3D.new()
 s.size=size
 return s

func add_shape(body:CollisionObject3D,size:Vector3):
 var c=CollisionShape3D.new()
 c.shape=shape_for(size)
 body.add_child(c)

func count_bodies()->int:
 var total=0
 for batch in batches:total+=batch.bodies.size()
 return total

func spawn(p:Vector3,intensity:float,kind:String):
 if not is_instance_valid(root) or world.quality_mode==0:return
 var quantity=mini(8,MAX_BODIES-count_bodies())
 if quantity<=0:return
 var batch=Node3D.new()
 root.add_child(batch)
 var floor_body=StaticBody3D.new()
 batch.add_child(floor_body)
 floor_body.position=Vector3(p.x,p.y-.20,p.z)
 floor_body.collision_layer=4
 floor_body.collision_mask=4
 add_shape(floor_body,Vector3(9,.35,9))
 var rng=RandomNumberGenerator.new()
 rng.seed=int(world.sim.seed_value)+int(world.sim.day)*37+roundi(p.x*19+p.z*11)
 var bodies=[]
 for i in range(quantity):
  var body=RigidBody3D.new()
  batch.add_child(body)
  var angle=rng.randf()*TAU
  var dir=Vector3(cos(angle),0,sin(angle))
  body.position=p+dir*rng.randf_range(.2,1.0)+Vector3.UP*rng.randf_range(.35,1.3)
  body.collision_layer=4
  body.collision_mask=4
  body.mass=rng.randf_range(.4,1.8)
  body.continuous_cd=true
  body.linear_damp=.3
  body.angular_damp=.25
  var phys=PhysicsMaterial.new()
  phys.friction=.75
  phys.bounce=.20
  body.physics_material_override=phys
  var size=Vector3(rng.randf_range(.18,.35),rng.randf_range(.15,.32),rng.randf_range(.25,.50))
  add_shape(body,size)
  world.block(body,Color("a18a72") if i%2==0 else Color("736e63"),Vector3.ZERO,size)
  body.linear_velocity=dir*rng.randf_range(1,2.5)*intensity+Vector3.UP*rng.randf_range(1.7,3.3)*intensity
  body.angular_velocity=Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-3,3))
  bodies.append(body)
 batches.append({"node":batch,"bodies":bodies,"life":5.0,"kind":kind})

func update(delta:float,paused:bool):
 for batch in batches.duplicate():
  for body in batch.bodies:
   if is_instance_valid(body) and body.freeze!=paused:body.freeze=paused
  if paused:continue
  batch.life=float(batch.life)-delta
  if batch.life<=0:
   if is_instance_valid(batch.node):batch.node.queue_free()
   batches.erase(batch)
