extends RefCounted
# A separately rendered, traversable underground level. The surface simulation
# is paused while the Creator explores; entrance, exits and discoveries persist.
const MAP=[
"###############",
"#S....#.......#",
"#.###.#.#####.#",
"#...#...#...#.#",
"###.#####.#.#.#",
"#...#.....#...#",
"#.###.###.###.#",
"#.....#...#...#",
"#.#####.###.#.#",
"#.....#.....#R#",
"###############"]
const OFFSET=Vector3(260,0,0)
const CELL=1.8
var world
var root:Node3D
var camera:Camera3D
var explorer:Node3D
var active=false
var found=false
var position=Vector2(1,1)
var previous_speed=1.0
var relic:Node3D
var message:Label3D

func reset(w,data={}):
 world=w
 active=false
 found=bool(data.get("found",false))
 position=Vector2(1,1)
func export_state()->Dictionary:return {"found":found}
func entrance()->Vector3:return world.ground(-73,0)
func tile(p:Vector2)->bool:
 var x=roundi(p.x)
 var z=roundi(p.y)
 return z>=0 and z<MAP.size() and x>=0 and x<MAP[z].length() and MAP[z][x]!="#"
func location(p:Vector2)->Vector3:return OFFSET+Vector3(p.x*CELL,0,p.y*CELL)
func build(parent:Node3D):
 root=parent
 root.hide()
 for z in range(MAP.size()):
  for x in range(MAP[z].length()):
   var p=location(Vector2(x,z))-OFFSET
   if MAP[z][x]=="#":
    world.block(root,Color("354c52"),p+Vector3.UP*.85,Vector3(CELL,1.7,CELL))
    if (x+z)%3==0:world.cone(root,Color("5f7776"),p+Vector3.UP*1.85,.5,.5,.12,5)
   else:
    world.block(root,Color("716d61").lerp(Color("525f5d"),float((x+z)%4)/4),p-Vector3.UP*.08,Vector3(CELL,.16,CELL))
    if (x+2*z)%7==0:
     world.cone(root,Color("6cbab5"),p+Vector3(.52,.29,-.48),.14,.58,.035,5,.55)
 root.position=OFFSET
 explorer=Node3D.new()
 root.add_child(explorer)
 world.sphere(explorer,Color("f2d9a4"),Vector3.UP*.45,Vector3(.48,.84,.48),.35)
 var light=OmniLight3D.new()
 explorer.add_child(light)
 light.position.y=1.2
 light.light_color=Color("f6d399")
 light.light_energy=1.4
 light.omni_range=7
 relic=Node3D.new()
 root.add_child(relic)
 relic.position=Vector3(13*CELL,0,9*CELL)
 for i in range(5):
  world.cone(relic,Color("7ce0cf"),Vector3(cos(i*TAU/5)*.25,.48,sin(i*TAU/5)*.25),.14,.96,.0,6,.8)
 relic.visible=not found
 message=Label3D.new()
 root.add_child(message)
 message.position=Vector3(7*CELL,2.0,-.6)
 message.text="GROTTA DELLE ORIGINI  ·  WASD / C per uscire"
 message.font_size=32
 message.pixel_size=.015
 message.modulate=Color("e4d5b4")
 message.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 camera=Camera3D.new()
 root.add_child(camera)
 camera.fov=48
 camera.far=70
 camera.current=false
 update_camera()
func enter(force=false)->bool:
 if not world.vast_world or active or not is_instance_valid(root):return false
 if not force and world.flat_dist(world.focus,entrance())>14:return false
 previous_speed=world.speed
 world.speed=0
 world.following=false
 world.set_tour(false)
 active=true
 position=Vector2(1,1)
 root.show()
 world.hud.hide()
 camera.make_current()
 update_camera()
 return true
func leave():
 if not active:return
 active=false
 root.hide()
 world.camera.make_current()
 world.hud.show()
 world.speed=previous_speed
 world.update_camera()
func move(direction:Vector2,dt:float):
 if not active:return
 var next=position+direction.limit_length(1)*dt*2.2
 # Axis-separated collision with a radius, preventing diagonal corner clipping.
 for axis in range(2):
  var p=position
  p[axis]=next[axis]
  var valid=true
  for d in [Vector2(-.17,-.17),Vector2(.17,-.17),Vector2(-.17,.17),Vector2(.17,.17)]:
   if not tile(p+d):valid=false;break
  if valid:position=p
 if position.distance_to(Vector2(13,9))<.42 and not found:
  found=true
  relic.hide()
  world.sim.energy=minf(100,float(world.sim.energy)+20)
  for v in world.sim.villages:v.knowledge+=8
  world.legend.log_event("Scoperta",-1,-1,"Il Creatore ha scoperto il cristallo delle origini.",entrance())
  world.legend.advance_goal(3)
  message.text="CRISTALLO SCOPERTO  ·  C per tornare in superficie"
 update_camera()
func update_camera():
 if not is_instance_valid(explorer):return
 explorer.position=Vector3(position.x*CELL,0,position.y*CELL)
 camera.position=explorer.position+Vector3(0,10,6.6)
 camera.look_at(explorer.global_position,Vector3.UP)
func tick(dt:float):
 var d=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 move(d,dt)
func report()->String:return "Grotta delle origini · "+("cristallo scoperto" if found else "da esplorare")
