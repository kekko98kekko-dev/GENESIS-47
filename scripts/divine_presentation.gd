extends RefCounted
# A visual layer on top of the existing, real miracle simulation.
# All nodes are owned by the effect root and automatically removed on reset.
var world
var active:Array=[]
var cursor:Node3D
func reset(w):
 world=w
 active=[]
 cursor=null
func cast(p:Vector3,kind:String):
 if not is_instance_valid(world.effects_root):return
 var harmful=kind in ["Meteorite","Vulcano","Fulmine","Tsunami","Incendio","Terremoto","Tornado","Epidemia","Carestia","Conflitto"]
 var tint=Color("ff9c59") if harmful else Color("b7f6d8")
 if kind in ["Tsunami","Pioggia","Lago"]:tint=Color("72dbe9")
 if kind in ["Fede","Conoscenza","Profeta"]:tint=Color("f2d38e")
 var n=Node3D.new()
 world.effects_root.add_child(n)
 n.position=p+Vector3.UP*.12
 var ring=TorusMesh.new()
 ring.inner_radius=.91
 ring.outer_radius=1.0
 ring.rings=48
 ring.ring_segments=10
 var rings=[]
 for i in range(3):
  var r=world.piece(n,ring,tint,Vector3.UP*(.08+i*.025),Vector3.ONE*(1+i*.36),1.3)
  r.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  rings.append(r)
 var light=OmniLight3D.new()
 n.add_child(light)
 light.position.y=2.2
 light.light_color=tint
 light.light_energy=4.0
 light.omni_range=12
 var particles=CPUParticles3D.new()
 n.add_child(particles)
 particles.amount=96 if harmful else 64
 particles.lifetime=1.3
 particles.one_shot=true
 particles.explosiveness=.85
 particles.emission_shape=CPUParticles3D.EMISSION_SHAPE_SPHERE
 particles.emission_sphere_radius=.75
 particles.direction=Vector3.UP
 particles.spread=65
 particles.gravity=Vector3(0,-3 if harmful else -.2,0)
 particles.initial_velocity_min=2.0
 particles.initial_velocity_max=6.0 if harmful else 3.8
 particles.scale_amount_min=.45
 particles.scale_amount_max=1.25
 var mote=SphereMesh.new()
 mote.radius=.065
 mote.height=.13
 mote.radial_segments=6
 mote.rings=4
 mote.material=world.material(tint,.4,1.5)
 particles.mesh=mote
 particles.emitting=true
 var pillars=[]
 if not harmful:
  for i in range(6):
   var angle=i*TAU/6
   var ray=world.cone(n,tint,Vector3(cos(angle)*1.65,1.4,sin(angle)*1.65),.055,2.8,.015,6,.9)
   ray.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
   pillars.append(ray)
 active.append({"node":n,"rings":rings,"light":light,"pillars":pillars,"time":0.0,"duration":2.1 if harmful else 2.6,"harmful":harmful})
func update(dt:float):
 for fx in active.duplicate():
  if not is_instance_valid(fx.node):active.erase(fx);continue
  fx.time=float(fx.time)+dt
  var t=clampf(float(fx.time)/float(fx.duration),0,1)
  for i in range(fx.rings.size()):
   var phase=clampf(t-float(i)*.12,0,1)
   var scale_value=.5+phase*(8 if fx.harmful else 5)
   fx.rings[i].scale=Vector3(scale_value,.55*(1-t),scale_value)
   fx.rings[i].visible=t<.87
  fx.light.light_energy=4.0*pow(1-t,2)
  for ray in fx.pillars:
   ray.scale.y=sin(PI*t)*2
   ray.rotation.y=t*2
  if t>=1:
   fx.node.queue_free()
   active.erase(fx)
func pointer(p:Vector3,visible:bool):
 if not visible:
  if is_instance_valid(cursor):cursor.hide()
  return
 if not is_instance_valid(cursor):
  cursor=Node3D.new()
  world.effects_root.add_child(cursor)
  var tint=Color("d6e9b4")
  world.sphere(cursor,tint,Vector3.ZERO,Vector3.ONE*.34,1.0)
  var ring=TorusMesh.new()
  ring.inner_radius=.39
  ring.outer_radius=.42
  var a=world.piece(cursor,ring,Color("f2d69e"),Vector3.ZERO,Vector3.ONE,.7)
  a.rotation.x=.75
  var b=world.piece(cursor,ring,Color("c0f3dc"),Vector3.ZERO,Vector3.ONE,.7)
  b.rotation.z=.9
 cursor.show()
 cursor.position=p+Vector3.UP*1.8
 cursor.rotation.y=world.visual_time*1.4
