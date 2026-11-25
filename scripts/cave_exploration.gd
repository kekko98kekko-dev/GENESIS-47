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
var secrets:Array=[]
var secret_nodes:Dictionary={}
var previous_sun=true
const SECRETS=[Vector2(5,1),Vector2(9,5)]
const SECRET_NAMES=["Tavoletta della prima lingua","Uovo fossile"]
var position=Vector2(1,1)
var previous_speed=1.0
var relic:Node3D
var message:Label3D

func reset(w,data={}):
 world=w
 active=false
 found=bool(data.get("found",false))
 secrets=data.get("secrets",[])
 secret_nodes.clear()
 position=Vector2(1,1)
func export_state()->Dictionary:return {"found":found,"secrets":secrets}
func entrance()->Vector3:return world.ground(-73,0)
func tile(p:Vector2)->bool:
 var x=roundi(p.x)
 var z=roundi(p.y)
 return z>=0 and z<MAP.size() and x>=0 and x<MAP[z].length() and MAP[z][x]!="#"
func location(p:Vector2)->Vector3:return OFFSET+Vector3(p.x*CELL,0,p.y*CELL)
func build(parent:Node3D):
 root=parent
 root.hide()
 world.block(root,Color("17282d"),Vector3(7*CELL,-.32,5*CELL),Vector3(15*CELL,.45,11*CELL))
 for z in range(MAP.size()):
  for x in range(MAP[z].length()):
   var p=location(Vector2(x,z))-OFFSET
   if MAP[z][x]=="#":
    world.block(root,Color("354c52").lerp(Color("26373c"),float((x*7+z*3)%5)/5),p+Vector3.UP*.85,Vector3(CELL,1.7,CELL))
    for k in range(2):
     var stone=world.cone(root,Color("496265"),p+Vector3((k-.5)*.62,1.68+float((x+z+k)%4)*.12,.12),.52,.9+float((x*z+k)%3)*.24,.09,5)
     stone.rotation.y=float(x+z+k)*1.37
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
 for i in range(SECRETS.size()):
  var secret=Node3D.new()
  root.add_child(secret)
  secret.position=Vector3(SECRETS[i].x*CELL,0,SECRETS[i].y*CELL)
  world.block(secret,Color("716856"),Vector3.UP*.15,Vector3(.78,.30,.72))
  if i==0:
   var tablet=world.block(secret,Color("b6a880"),Vector3.UP*.55,Vector3(.54,.62,.12),.15)
   tablet.rotation.x=-.32
   for j in range(3):world.block(secret,Color("5e7067"),Vector3(0,.36+j*.13,.12),Vector3(.31,.033,.05))
  else:
   world.sphere(secret,Color("c9b49b"),Vector3.UP*.54,Vector3(.46,.63,.43),.12)
  secret.visible=not secrets.has(i)
  secret_nodes[i]=secret
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
 var cave_env=Environment.new()
 cave_env.background_mode=Environment.BG_COLOR
 cave_env.background_color=Color("101b20")
 cave_env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 cave_env.ambient_light_color=Color("7c9d9d")
 cave_env.ambient_light_energy=.36
 camera.environment=cave_env
 update_camera()
func enter(force=false)->bool:
 if not world.vast_world or active or not is_instance_valid(root):return false
 if not force and world.flat_dist(world.focus,entrance())>14:return false
 previous_speed=world.speed
 world.speed=0
 world.following=false
 world.set_tour(false)
 active=true
 previous_sun=world.sun.visible
 world.sun.hide()
 position=Vector2(1,1)
 root.show()
 world.hud.hide()
 camera.make_current()
 update_camera()
 return true
func leave():
 if not active:return
 active=false
 world.sun.visible=previous_sun
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
 for i in range(SECRETS.size()):
  if not secrets.has(i) and position.distance_to(SECRETS[i])<.42:
   secrets.append(i)
   if secret_nodes.has(i):secret_nodes[i].hide()
   for v in world.sim.villages:v.knowledge+=4
   world.legend.log_event("Archeologia",-1,-1,"Scoperto: "+SECRET_NAMES[i],entrance())
   world.legacy.record("Archeologia",-1,-1,SECRET_NAMES[i],entrance())
   message.text=SECRET_NAMES[i]+" · scoperta registrata"
 update_camera()
func update_camera():
 if not is_instance_valid(explorer):return
 explorer.position=Vector3(position.x*CELL,0,position.y*CELL)
 camera.position=explorer.position+Vector3(0,7.8,5.6)
 camera.look_at(explorer.global_position,Vector3.UP)
func tick(dt:float):
 var d=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 move(d,dt)
func report()->String:return "Grotta delle origini · "+("cristallo scoperto" if found else "da esplorare")+" · reperti "+str(secrets.size())+"/2"
