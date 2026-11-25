extends Control
var world
var cache:ImageTexture
var cached_seed=-1
var cached_deformation=-1
var cached_extent=0.0
func extent()->float:return 96.0 if world.vast_world else 52.0
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP
 tooltip_text="Clicca per spostare la telecamera"
func _process(_delta):
 if world!=null:queue_redraw()
func _draw():
 if world==null or world.centers.size()!=2:return
 if cache==null or cached_seed!=world.sim.seed_value or cached_deformation!=world.terrain_revision or cached_extent!=extent():
  cached_extent=extent()
  cached_seed=world.sim.seed_value
  cached_deformation=world.terrain_revision
  var image=Image.create(72,72,false,Image.FORMAT_RGB8)
  for y in range(72):
   for x in range(72):
    var h=world.height_at(float(x)/71*extent()*2-extent(),float(y)/71*extent()*2-extent())
    var c=Color("25565b") if h<world.SEA else Color("7eac78").lerp(Color("c3bc95"),clampf(h/13.0,0,1))
    image.set_pixel(x,y,c)
  cache=ImageTexture.create_from_image(image)
 draw_texture_rect(cache,Rect2(Vector2.ZERO,size),false)
 for i in range(world.trade_route.size()-1):
  draw_line(to_map(world.trade_route[i]),to_map(world.trade_route[i+1]),Color("d2af79"),1.2,true)
 if world.expanded_world:
  for link in ([] if world.ocean.enabled else world.REGION_BRIDGES):
   draw_line(to_map(Vector3(link[0].x,0,link[0].y)),to_map(Vector3(link[1].x,0,link[1].y)),Color("d2af79"),1.2,true)
  for i in range(1,world.REGION_POINTS.size()):
   var p:Vector2=world.REGION_POINTS[i]
   draw_arc(to_map(Vector3(p.x,0,p.y)),4,0,TAU,16,Color("f5dda1"),1.0,true)
 if world.ocean.enabled:
  for row in world.ocean.voyages:
   var ship=world.ocean.fleet.get(int(row.id))
   if is_instance_valid(ship):draw_circle(to_map(ship.position),2.6,Color("fff0bd"))
  for colony in world.ocean.colonies:
   var point:Vector2=world.REGION_POINTS[int(colony.region)]
   draw_circle(to_map(Vector3(point.x,0,point.y)),3.0,Color("9ff0bb") if int(colony.clan)==0 else Color("f3b97e"))
 if world.ocean.enabled:
  for id in world.ocean.life.actors:
   var colonist=world.ocean.life.actors[id]
   if is_instance_valid(colonist.node):draw_circle(to_map(colonist.node.position),1.65,Color("ffdba4"))
 for a in world.sim.people:
  if not world.actors.has(a.id):continue
  var p=world.actors[a.id].node.position
  draw_circle(to_map(p),1.65,Color("d2fff0") if a.clan==0 else Color("ffcf92"))
 for i in range(2):draw_arc(to_map(world.centers[i]),6,0,TAU,24,Color.WHITE,1.0,true)
 draw_arc(to_map(world.focus),8,0,TAU,24,Color("f4efb0"),1.8,true)
 draw_rect(Rect2(Vector2.ZERO,size),Color("8dbca8"),false,1)
func to_map(p:Vector3)->Vector2:
 return Vector2((p.x+extent())/(extent()*2)*size.x,(p.z+extent())/(extent()*2)*size.y)
func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and world!=null:
  var p=event.position/size*extent()*2-Vector2.ONE*extent()
  world.focus=Vector3(p.x,0,p.y)
  world.following=false
  world.update_camera()
  accept_event()
