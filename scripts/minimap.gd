extends Control
var world
var cache:ImageTexture
var cached_seed=-1
var cached_deformation=-1
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP
 tooltip_text="Clicca per spostare la telecamera"
func _process(_delta):
 if world!=null:queue_redraw()
func _draw():
 if world==null or world.centers.size()!=2:return
 if cache==null or cached_seed!=world.sim.seed_value or cached_deformation!=world.deformation.size():
  cached_seed=world.sim.seed_value
  cached_deformation=world.deformation.size()
  var image=Image.create(72,72,false,Image.FORMAT_RGB8)
  for y in range(72):
   for x in range(72):
    var h=world.height_at(float(x)/71*104-52,float(y)/71*104-52)
    var c=Color("25565b") if h<world.SEA else Color("7eac78").lerp(Color("c3bc95"),clampf(h/13.0,0,1))
    image.set_pixel(x,y,c)
  cache=ImageTexture.create_from_image(image)
 draw_texture_rect(cache,Rect2(Vector2.ZERO,size),false)
 for a in world.sim.people:
  if not world.actors.has(a.id):continue
  var p=world.actors[a.id].node.position
  draw_circle(to_map(p),1.65,Color("d2fff0") if a.clan==0 else Color("ffcf92"))
 for i in range(2):draw_arc(to_map(world.centers[i]),6,0,TAU,24,Color.WHITE,1.0,true)
 draw_arc(to_map(world.focus),8,0,TAU,24,Color("f4efb0"),1.8,true)
 draw_rect(Rect2(Vector2.ZERO,size),Color("8dbca8"),false,1)
func to_map(p:Vector3)->Vector2:
 return Vector2((p.x+52)/104*size.x,(p.z+52)/104*size.y)
func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and world!=null:
  var p=event.position/size*104-Vector2(52,52)
  world.focus=Vector3(p.x,0,p.y)
  world.following=false
  world.update_camera()
  accept_event()
