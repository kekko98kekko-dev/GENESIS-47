extends Node3D
const Sim=preload("res://scripts/sim.gd")
const SEA=-0.40
const GRID=92
const STEP=1.15
const POWERS=["Osserva","Vita","Foresta","Provviste","Guarigione","Meteorite","Conoscenza","Pace","Mutazione","Pioggia","Conflitto","Fede","Fulmine","Tsunami","Vulcano","Resurrezione","Montagna","Lago","Profeta","Nuova specie","Carestia"]
const SAVE_PREFIX="user://genesis47_slot"
var sim=Sim.new()
var rng=RandomNumberGenerator.new()
var noise=FastNoiseLite.new()
var art_catalog:Dictionary={}
var scenes:Dictionary={}
var materials:Dictionary={}
var earth:MeshInstance3D
var sea:MeshInstance3D
var scenery:Node3D
var villages_root:Node3D
var people_root:Node3D
var animals_root:Node3D
var effects_root:Node3D
var actors:Dictionary={}
var animals:Array=[]
var houses:Array=[[],[]]
var hubs:Array=[]
var centers:Array=[]
var effects:Array=[]
var deformation:Array=[]
var camera:Camera3D
var sun:DirectionalLight3D
var env:Environment
var sky_material:ProceduralSkyMaterial
var focus=Vector3.ZERO
var azimuth=.83
var pitch=.88
var distance=91.0
var speed=1.0
var tick=0.0
var selected=-1
var following=false
var power="Osserva"
var unlimited=false
var show_ending=true
var photo_mode=false
var slot=0
var hud:Control
var top:Label
var title:Label
var details:RichTextLabel
var chronicle:RichTextLabel
var objective:Label
var hint:Label
var power_label:Label
var input:LineEdit
var model:LineEdit
var request:HTTPRequest
var request_target=-1
var audio:AudioStreamPlayer
var cursor:MeshInstance3D
var weather_timer=0.0
var test_mode=false
var visual_time=0.0
var farms_root:Node3D
var farm_points:Array=[[],[]]
var caravans:Array=[]
var roads_root:Node3D
var compact=false
var left_panel:Control
var right_panel:Control
var bottom_panel:Control
var signals_button:Button
var time_buttons:Array=[]
var quality_mode=1
var hover_ring:MeshInstance3D
var ambient_root:Node3D
var clouds:Array=[]
var settings=ConfigFile.new()
var autosave_enabled=true
var last_auto_day=-1
var previous_speed=1.0
var selected_slot:OptionButton
var volume_value=50.0
var cinematic_light=false
var hover_elapsed=0.0
var event_player:AudioStreamPlayer
var event_sounds:Dictionary={}
var atlas_window:AcceptDialog
var portable_ai=false
var ai_test=false
var ai_reply_received=false
var ai_autonomy=true
var ai_busy=false
var ai_is_autonomous=false
var ai_cooldown=0.0
var last_ai_day=-1
var absent_progress=false
var ai_button:Button
var toast_panel:PanelContainer
var toast_label:Label
var toast_time=0.0
var planted:Array=[]
var snow_mesh:SphereMesh
var rain_mesh:BoxMesh
var civic_root:Node3D
var civic_spinners:Array=[]
var status_bar:ProgressBar
var stats_bar:Label
var day_label:Label
var last_project_count=0
var welcome_open=false
var world_started=false
var last_crises=0
var path_shader=preload("res://shaders/path.gdshader")
var health_fill:StyleBoxFlat
var precipitation:CPUParticles3D
var map_view:Control
var activity_labels={}
var show_labels=false
var power_buttons:Array=[]
var power_category:OptionButton
var power_grid:VBoxContainer
var help_dialog:AcceptDialog
var selected_status:Label
const GROUPS=[["Osserva","Vita","Foresta","Provviste","Guarigione","Pioggia","Resurrezione"],["Conoscenza","Pace","Fede","Profeta","Mutazione","Nuova specie"],["Meteorite","Conflitto","Fulmine","Tsunami","Vulcano","Carestia"],["Montagna","Lago"]]
const POWER_TIPS={"Osserva":"Seleziona un abitante senza modificarlo.","Vita":"Crea un abitante nel popolo più vicino.","Foresta":"Pianta alberi e aggiunge legna.","Provviste":"Aggiunge 100 unità di cibo.","Guarigione":"Ripristina salute e cura malattie in un raggio di 6 m.","Pioggia":"Aumenta le risorse alimentari.","Resurrezione":"Riporta in vita un abitante defunto.","Conoscenza":"Accelera la ricerca del popolo.","Pace":"Migliora le relazioni fra le civiltà.","Fede":"Aumenta la fiducia nel Creatore.","Profeta":"Ispira un profeta persistente.","Mutazione":"Cambia i tratti genetici degli abitanti vicini.","Nuova specie":"Genera un individuo con tratti casuali.","Meteorite":"Danneggia la zona e scava un cratere.","Conflitto":"Riduce la pace fra i popoli.","Fulmine":"Colpisce gli abitanti nelle vicinanze.","Tsunami":"Danneggia abitanti e scorte.","Vulcano":"Solleva il terreno e scatena un'eruzione.","Carestia":"Riduce le scorte alimentari.","Montagna":"Solleva il terreno.","Lago":"Abbassa il terreno."}

func _ready():
 portable_ai="--portable-ai" in OS.get_cmdline_user_args()
 ai_test="--ai-test" in OS.get_cmdline_user_args()
 test_mode="--self-test" in OS.get_cmdline_user_args() or ai_test
 load_catalog()
 setup_environment()
 setup_ui()
 if not test_mode and not "--capture" in OS.get_cmdline_user_args():restore_settings()
 request=HTTPRequest.new()
 add_child(request)
 request.timeout=90
 request.request_completed.connect(ai_response)
 new_world(47,0)
 if ai_test:
  call_deferred("self_test_ai")
 elif test_mode:
  call_deferred("self_test")
 elif "--capture" in OS.get_cmdline_user_args():
  call_deferred("capture_preview")
 else:
  get_tree().auto_accept_quit=false
  open_welcome()

func load_catalog():
 var p="res://assets/generated/catalog.json"
 if FileAccess.file_exists(p):
  var data=JSON.parse_string(FileAccess.get_file_as_string(p))
  if data is Dictionary:art_catalog=data
 for key in art_catalog:
  var verified=[]
  for path in art_catalog[key]:
   if ResourceLoader.exists(path):
    var res=load(path)
    if res is PackedScene:
     scenes[path]=res
     verified.append(path)
  art_catalog[key]=verified
 print("Imported model counts: ",art_catalog.keys().map(func(k):return str(k)+":"+str(art_catalog[k].size())))

func material(c:Color,rough=0.85,glow=0.0)->StandardMaterial3D:
 var key=str(c)+str(rough)+str(glow)
 if not materials.has(key):
  var m=StandardMaterial3D.new()
  m.albedo_color=c
  m.roughness=rough
  if glow>0:
   m.emission_enabled=true
   m.emission=c
   m.emission_energy_multiplier=glow
  materials[key]=m
 return materials[key]

func piece(parent:Node3D,mesh:Mesh,c:Color,p:Vector3,s=Vector3.ONE,glow=0.0)->MeshInstance3D:
 var n=MeshInstance3D.new()
 n.mesh=mesh
 n.material_override=material(c,.75,glow)
 parent.add_child(n)
 n.position=p
 n.scale=s
 return n

func sphere(parent:Node3D,c:Color,p:Vector3,s:Vector3,glow=0.0)->MeshInstance3D:
 var m=SphereMesh.new()
 m.radius=.5
 m.height=1.0
 m.radial_segments=16
 m.rings=8
 return piece(parent,m,c,p,s,glow)

func block(parent:Node3D,c:Color,p:Vector3,s:Vector3,glow=0.0)->MeshInstance3D:
 var m=BoxMesh.new()
 m.size=Vector3.ONE
 return piece(parent,m,c,p,s,glow)

func cone(parent:Node3D,c:Color,p:Vector3,r:float,h:float,upper=0.0,sides=9,glow=0.0)->MeshInstance3D:
 var m=CylinderMesh.new()
 m.top_radius=upper
 m.bottom_radius=r
 m.height=h
 m.radial_segments=sides
 return piece(parent,m,c,p,Vector3.ONE,glow)

func choose_asset(kind:String,index:int)->String:
 var list=art_catalog.get(kind,[])
 if list.is_empty():return ""
 return str(list[posmod(index,list.size())])

func mesh_bounds(n:Node3D,root:Node3D)->Array:
 var result=[]
 if n is MeshInstance3D and n.mesh!=null:
  var t=root.global_transform.affine_inverse()*n.global_transform
  result.append(t*n.get_aabb())
 for child in n.get_children():
  if child is Node3D:result.append_array(mesh_bounds(child,root))
 return result

func animation_player(n:Node)->AnimationPlayer:
 if n is AnimationPlayer:return n
 for child in n.get_children():
  var found=animation_player(child)
  if found!=null:return found
 return null

func start_animation(n:Node,preferred:Array):
 var ap=animation_player(n)
 if ap==null:return
 var list=ap.get_animation_list()
 for term in preferred:
  for anim in list:
   if str(anim).to_lower().contains(term):
    var clip=ap.get_animation(anim)
    if clip!=null:clip.loop_mode=Animation.LOOP_LINEAR
    ap.play(anim)
    return
 for anim in list:
  if str(anim)!="RESET":
   var clip=ap.get_animation(anim)
   if clip!=null:clip.loop_mode=Animation.LOOP_LINEAR
   ap.play(anim)
   return

func asset(parent:Node3D,kind:String,index:int,p:Vector3,height:float,angle=0.0)->Node3D:
 var path=choose_asset(kind,index)
 if path=="":return null
 var holder=Node3D.new()
 parent.add_child(holder)
 holder.position=p
 var item=scenes[path].instantiate()
 if not item is Node3D:
  holder.queue_free()
  return null
 holder.add_child(item)
 var bounds=mesh_bounds(item,holder)
 if bounds.is_empty():
  holder.queue_free()
  return null
 var box:AABB=bounds[0]
 for b in bounds:box=box.merge(b)
 var scale_value=height/maxf(.01,box.size.y)
 item.scale*=scale_value
 item.position+=Vector3(-box.get_center().x,-box.position.y,-box.get_center().z)*scale_value
 holder.rotation.y=angle
 return holder

func setup_environment():
 env=Environment.new()
 env.background_mode=Environment.BG_SKY
 var sky=Sky.new()
 sky_material=ProceduralSkyMaterial.new()
 sky_material.sky_top_color=Color("4d86b4")
 sky_material.sky_horizon_color=Color("cfdfd4")
 sky_material.ground_bottom_color=Color("244a50")
 sky_material.ground_horizon_color=Color("becfc6")
 sky_material.sun_angle_max=22
 sky.sky_material=sky_material
 env.sky=sky
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color("d2e2e7")
 env.ambient_light_energy=.40
 env.fog_enabled=true
 env.fog_light_color=Color("afc8cf")
 env.fog_density=.0025
 var en=WorldEnvironment.new()
 en.environment=env
 add_child(en)
 sun=DirectionalLight3D.new()
 add_child(sun)
 sun.rotation_degrees=Vector3(-53,-37,0)
 sun.light_color=Color("fff0cc")
 sun.light_energy=.90
 sun.shadow_enabled=true
 sun.directional_shadow_max_distance=115
 camera=Camera3D.new()
 add_child(camera)
 camera.current=true
 camera.fov=45
 camera.far=300
 camera.near=.07
 precipitation=CPUParticles3D.new()
 add_child(precipitation)
 precipitation.emitting=false
 precipitation.amount=600
 precipitation.lifetime=1.65
 precipitation.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
 precipitation.emission_box_extents=Vector3(18,1,18)
 precipitation.direction=Vector3(.1,-1,.04)
 precipitation.spread=8
 precipitation.gravity=Vector3(0,-12,0)
 precipitation.initial_velocity_min=7
 precipitation.initial_velocity_max=10
 var drop=BoxMesh.new()
 drop.size=Vector3(.027,.32,.027)
 drop.material=material(Color("b7d8df"),.65,.1)
 precipitation.mesh=drop
 rain_mesh=drop
 snow_mesh=SphereMesh.new()
 snow_mesh.radius=.07
 snow_mesh.height=.14
 snow_mesh.radial_segments=6
 snow_mesh.rings=3
 snow_mesh.material=material(Color("e7f3f5"),.9,.1)
 audio=AudioStreamPlayer.new()
 add_child(audio)
 event_player=AudioStreamPlayer.new()
 add_child(event_player)
 event_player.volume_db=-18
 if not test_mode and not "--capture" in OS.get_cmdline_user_args():
  create_soundscape()

func create_soundscape():
 var rate=16000
 var frames=rate*8
 var data=PackedByteArray()
 data.resize(frames*2)
 for i in range(frames):
  var t=float(i)/rate
  var tide=.62+.38*sin(TAU*t/8.0)
  var tone=sin(TAU*110.0*t)*.13+sin(TAU*164.0*t)*.08+sin(TAU*220.0*t)*.04
  var wind=sin(TAU*37.0*t+sin(TAU*t*.25)*2.0)*.018
  data.encode_s16(i*2,int((tone*tide+wind)*24000))
 var wav=AudioStreamWAV.new()
 wav.format=AudioStreamWAV.FORMAT_16_BITS
 wav.mix_rate=rate
 wav.data=data
 wav.loop_mode=AudioStreamWAV.LOOP_FORWARD
 wav.loop_end=frames
 audio.stream=wav
 audio.volume_db=-25
 audio.play()

func height_at(x:float,z:float)->float:
 var d=Vector2(x/47.5,z/43.5).length()
 var h=5.9*(1.0-pow(d,2.1))-1.35
 h+=noise.get_noise_2d(x,z)*5.4+noise.get_noise_2d(x*2.8+131,z*2.8)*.75
 h+=9.0*exp(-Vector2(x+24,z+19).length_squared()/112.0)
 h+=4.5*exp(-Vector2(x-22,z-22).length_squared()/160.0)
 var stream=x-4.2*sin(z*.105)
 if absf(z)<32:
  h-=2.3*exp(-stream*stream/7.0)*clampf((36-absf(z))/8,0,1)
 for q in deformation:
  var dd=Vector2(x-float(q.x),z-float(q.z)).length()
  if dd<float(q.r):
   h+=float(q.h)*pow(1.0-dd/float(q.r),2.0)
 return h

func ground(x:float,z:float)->Vector3:
 return Vector3(x,height_at(x,z),z)

func land_near(x:float,z:float)->Vector3:
 for i in range(35):
  var p=ground(x,z)
  if p.y>SEA+.7:return p
  x*=.91
  z*=.91
 return ground(-12,6)

func random_near(center:Vector3,r:float)->Vector3:
 for i in range(20):
  var p=ground(center.x+rng.randf_range(-r,r),center.z+rng.randf_range(-r,r))
  if p.y>SEA+.25:return p
 return center

func terrain_color(p:Vector3)->Color:
 var v=clampf(noise.get_noise_2d(p.x*3+300,p.z*3)*.65+.5,0,1)
 if p.y<SEA+.16:return Color("a89472")
 if p.y<SEA+.75:return Color("d9c89c").lerp(Color("b3bb79"),clampf((p.y-SEA)/.75,0,1))
 if p.y>10:return Color("a3a99e").lerp(Color("e7e7dc"),clampf((p.y-10)/4,0,1))
 if p.y>7.5:return Color("8c917c").lerp(Color("a8a69c"),clampf((p.y-7.5)/3,0,1))
 var grass=Color("315f49").lerp(Color("9db46a"),v)
 var broad=clampf(noise.get_noise_2d(p.x*.45+97,p.z*.45)*.8+.5,0,1)
 grass=grass.lerp(Color("7b9560"),broad*.24)
 for c in centers:
  if Vector2(p.x-c.x,p.z-c.z).length()<6:
   grass=grass.lerp(Color("b0a280"),.35)
 return grass

func make_terrain():
 if is_instance_valid(earth):
  remove_child(earth)
  earth.queue_free()
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for iz in range(GRID):
  for ix in range(GRID):
   var x=(ix-GRID*.5)*STEP
   var z=(iz-GRID*.5)*STEP
   var a=ground(x,z)
   var b=ground(x+STEP,z)
   var c=ground(x,z+STEP)
   var d=ground(x+STEP,z+STEP)
   for p in [a,b,c,b,d,c]:
    st.set_color(terrain_color(p))
    st.add_vertex(p)
 st.index()
 st.generate_normals()
 earth=MeshInstance3D.new()
 earth.mesh=st.commit()
 var m=ShaderMaterial.new()
 m.shader=preload("res://shaders/terrain.gdshader")
 earth.material_override=m
 add_child(earth)
 if not is_instance_valid(sea):
  sea=MeshInstance3D.new()
  var wm=PlaneMesh.new()
  wm.size=Vector2(230,230)
  wm.subdivide_width=100
  wm.subdivide_depth=100
  sea.mesh=wm
  var sm=ShaderMaterial.new()
  sm.shader=preload("res://shaders/water.gdshader")
  sea.material_override=sm
  add_child(sea)
  sea.position.y=SEA
  sea.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var depth_image=Image.create(128,128,false,Image.FORMAT_RGB8)
 for dz in range(128):
  for dx in range(128):
   var h=height_at(float(dx)/127*106-53,float(dz)/127*106-53)
   var v=clampf((h+5.0)/20.0,0,1)
   depth_image.set_pixel(dx,dz,Color(v,v,v))
 sea.material_override.set_shader_parameter("height_map",ImageTexture.create_from_image(depth_image))

func new_world(seed_value:int,which:int):
 reset_ai_request()
 planted.clear()
 sim.start(seed_value,which)
 last_auto_day=-1
 reset_visuals()
 tick=0
 selected=-1
 following=false
 speed=1
 show_ending=true
 power="Osserva"
 refresh()

func reset_visuals():
 for n in [earth,sea,scenery,villages_root,people_root,animals_root,effects_root,cursor,roads_root,farms_root,hover_ring,ambient_root,civic_root]:
  if is_instance_valid(n):
   remove_child(n)
   n.queue_free()
 earth=null
 sea=null
 actors.clear()
 activity_labels.clear()
 caravans.clear()
 clouds.clear()
 civic_spinners.clear()
 farm_points=[[],[]]
 animals.clear()
 effects.clear()
 houses=[[],[]]
 centers.clear()
 hubs.clear()
 rng.seed=sim.seed_value+37
 noise.seed=sim.seed_value
 noise.frequency=.044
 noise.fractal_octaves=4
 centers=[land_near(-15,9),land_near(19,-6)]
 make_terrain()
 scenery=Node3D.new()
 villages_root=Node3D.new()
 people_root=Node3D.new()
 animals_root=Node3D.new()
 effects_root=Node3D.new()
 roads_root=Node3D.new()
 farms_root=Node3D.new()
 ambient_root=Node3D.new()
 civic_root=Node3D.new()
 for n in [scenery,villages_root,people_root,animals_root,effects_root,roads_root,farms_root,ambient_root,civic_root]:add_child(n)
 create_clouds()
 for i in range(2):
  make_hub(i)
  sync_houses(i)
 rebuild_roads()
 rebuild_farms()
 rebuild_civic()
 for i in range(350):
  var p=ground(rng.randf_range(-45,45),rng.randf_range(-42,42))
  if p.y>SEA+.85 and p.y<8.5 and far_village(p,9):
   make_tree(p,rng.randf_range(2.3,4.8),i)
 for row in planted:
  var place=ground(float(row.x),float(row.z))
  if place.y>SEA+.12:make_tree(place,float(row.h),int(row.i))
 for i in range(100):
  var p=ground(rng.randf_range(-46,46),rng.randf_range(-43,43))
  if p.y>SEA+.2 and far_village(p,4):
   make_rock(p,rng.randf_range(.45,1.3),i)
 for i in range(110):
  var p=ground(rng.randf_range(-40,40),rng.randf_range(-38,38))
  if p.y>SEA+.4 and p.y<6.8 and far_village(p,2.0):
   for j in range(3):
    var q=p+Vector3(rng.randf_range(-.4,.4),.18,rng.randf_range(-.4,.4))
    sphere(scenery,Color("ebc777") if i%3==0 else Color("91aa67"),q,Vector3(.11,.28,.11))
 for i in range(14):
  var p=random_near(centers[i%2],13)
  var n=asset(animals_root,"animal",i,p,rng.randf_range(.65,1.3),rng.randf()*TAU)
  if n==null:
   n=Node3D.new()
   animals_root.add_child(n)
   n.position=p
   sphere(n,Color("c9b28c"),Vector3(0,.4,0),Vector3(.56,.5,.88))
   sphere(n,Color("dfc6a1"),Vector3(0,.6,.48),Vector3(.36,.40,.38))
   for k in [-1,1]:
    for j in [-1,1]:sphere(n,Color("a78c6f"),Vector3(k*.18,.17,j*.25),Vector3(.13,.34,.14))
  start_animation(n,["walk","run","idle"])
  animals.append({"node":n,"target":random_near(p,5),"center":centers[i%2],"phase":rng.randf()*TAU})
 for a in sim.people:create_actor(a)
 sim.changes.clear()
 cursor=MeshInstance3D.new()
 var ring=TorusMesh.new()
 ring.inner_radius=.43
 ring.outer_radius=.49
 cursor.mesh=ring
 cursor.material_override=material(Color("fff0b3"),.5,1.1)
 add_child(cursor)
 cursor.hide()
 hover_ring=MeshInstance3D.new()
 var brush=TorusMesh.new()
 brush.inner_radius=5.85
 brush.outer_radius=6.0
 hover_ring.mesh=brush
 hover_ring.material_override=material(Color("e4ad66"),.7,.5)
 hover_ring.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(hover_ring)
 hover_ring.hide()
 focus=Vector3.ZERO
 distance=91
 update_camera()

func far_village(p:Vector3,r:float)->bool:
 for c in centers:
  if Vector2(p.x-c.x,p.z-c.z).length()<r:return false
 return true

func make_tree(p:Vector3,h:float,i:int):
 var n=asset(scenery,"tree",i,p,h,rng.randf()*TAU)
 if n!=null:return
 n=Node3D.new()
 scenery.add_child(n)
 n.position=p
 n.scale=Vector3.ONE*h/3.2
 cone(n,Color("795d47"),Vector3(0,.9,0),.15,1.8,.08,7)
 if i%3==0:
  for j in range(3):
   cone(n,[Color("416d51"),Color("648d5a"),Color("8cac70")][j],Vector3(0,1.5+j*.55,0),1.0-j*.19,1.45,.04,9)
 else:
  for j in range(5):
   var angle=j*TAU/5
   sphere(n,[Color("54794f"),Color("76a065"),Color("8dae6d")][j%3],Vector3(cos(angle)*.45,2.0+sin(angle)*.22,sin(angle)*.43),Vector3(1.35,1.15,1.35))
  sphere(n,Color("92ad6b"),Vector3(0,2.7,0),Vector3(1.05,.95,1.05))

func make_rock(p:Vector3,h:float,i:int):
 if asset(scenery,"rock",i,p,h,rng.randf()*TAU)!=null:return
 var n=sphere(scenery,Color("9b9d89").lerp(Color("676f6c"),rng.randf()),p+Vector3(0,h*.28,0),Vector3(h*1.2,h*.7,h*.9))
 n.rotation=Vector3(rng.randf()*.2,rng.randf()*TAU,rng.randf()*.2)

func make_hub(i:int):
 var n=Node3D.new()
 villages_root.add_child(n)
 n.position=centers[i]
 hubs.append(n)
 cone(n,Color("978668"),Vector3(0,.025,0),1.85,.12,1.85,24)
 if asset(n,"prop",i,Vector3(0,.1,0),1.0)==null:
  for j in range(7):
   var a=j*TAU/7
   sphere(n,Color("8c8779"),Vector3(cos(a)*.58,.18,sin(a)*.58),Vector3(.44,.33,.43))
  cone(n,Color("faae58"),Vector3(0,.66,0),.33,.92,.02,9,1.1)
 var l=OmniLight3D.new()
 n.add_child(l)
 l.position.y=1.25
 l.light_color=Color("ffc18b")
 l.light_energy=.25
 l.omni_range=4.5
 var flag=Color("6eb5a1") if i==0 else Color("d0a068")
 cone(n,Color("80684d"),Vector3(-1.6,1.6,0),.045,3.2,.035,7)
 block(n,flag,Vector3(-1.17,2.65,0),Vector3(.85,.53,.045))
 var label=Label3D.new()
 n.add_child(label)
 label.text=Sim.CLANS[i]
 label.font_size=45
 label.outline_size=8
 label.pixel_size=.012
 label.position=Vector3(0,3.9,0)
 label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 label.modulate=Color("fff2cd")

func house_location(i:int,j:int)->Vector3:
 var a=j*2.39996+i*.5
 var r=4.5+sqrt(float(j))*2.9
 return land_near(centers[i].x+cos(a)*r,centers[i].z+sin(a)*r)

func make_house(i:int,j:int,era:int):
 var p=house_location(i,j)
 var n=Node3D.new()
 villages_root.add_child(n)
 n.position=p
 n.rotation.y=j*2.39996
 var roof=Color("a96847") if i==0 else Color("467b83")
 var kind="house" if era<4 else ("industrial" if era==4 else "future")
 var imported:Node3D=null
 if era>=2 and era<5:imported=asset(n,kind,j+i*3,Vector3.ZERO,3.0+float(era)*.48)
 elif era==1:imported=asset(n,"early",j+i*2,Vector3.ZERO,2.45)
 if imported==null:
  if era<2:
   cone(n,Color("d3b98a"),Vector3(0,.63,0),.91,1.26,.75,10)
   cone(n,roof,Vector3(0,1.51,0),1.15,1.08,.025,10)
   block(n,Color("5a4d39"),Vector3(0,.40,.86),Vector3(.39,.78,.10))
   for j2 in range(6):
    var a=j2*TAU/6
    cone(n,Color("b79a6e"),Vector3(cos(a)*.88,.6,sin(a)*.88),.035,1.1,.03,6)
  elif era<4:
   block(n,Color("dbccad"),Vector3(0,.95,0),Vector3(1.95,1.9,1.65))
   piece(n,PrismMesh.new(),roof,Vector3(0,2.28,0),Vector3(2.22,1.05,1.95))
   for xx in [-.63,.63]:
    block(n,Color("5b4e3d"),Vector3(xx,1.16,.86),Vector3(.40,.52,.07))
    block(n,Color("ffcf85"),Vector3(xx,1.16,.908),Vector3(.28,.38,.03),.2)
   block(n,Color("72533e"),Vector3(0,.48,.855),Vector3(.43,.96,.11))
   for xx in [-.91,.91]:block(n,Color("967351"),Vector3(xx,.95,.86),Vector3(.10,1.9,.1))
  else:
   var h=2.2+float(era-3)*.9
   block(n,Color("8eaaa9") if era>=5 else Color("aa9b87"),Vector3(0,h*.5,0),Vector3(1.8,h,1.55))
   block(n,Color("587779"),Vector3(0,h+.08,0),Vector3(1.96,.19,1.7))
   for k in range(1,era+1):
    var yy=h*float(k)/float(era+1)
    for xx in [-.56,0,.56]:block(n,Color("91e5d8") if era>=5 else Color("ffcd86"),Vector3(xx,yy,.79),Vector3(.34,.18,.04),.65)
   if era>=5:
    cone(n,Color("9ac5be"),Vector3(0,h+.48,0),.4,.85,.04,10)
    sphere(n,Color("95f1e1"),Vector3(0,h+.92,0),Vector3(.22,.22,.22),1.4)
    asset(n,"future",j,Vector3(1.3,0,0),1.9)
   else:cone(n,Color("786a60"),Vector3(.65,h+.5,0),.16,1.0,.16,10)
 if j%3==1 and era>=2:
  asset(n,"prop",j,Vector3(1.3,0,.55),.55)
 if j%3==0:
  for row in range(3):
   for col in range(4):
    var q=Vector3(-1.7+col*.24,.04,1.25+row*.27)
    block(n,Color("806847"),q,Vector3(.20,.06,.23))
    sphere(n,Color("98ad5e"),q+Vector3(0,.14,0),Vector3(.14,.26,.14))
 return n

func sync_houses(i:int):
 var v=sim.villages[i]
 while houses[i].size()>int(v.houses):
  var old=houses[i].pop_back()
  old.node.queue_free()
 for j in range(int(v.houses)):
  if j<houses[i].size():
   if houses[i][j].era==v.era:continue
   houses[i][j].node.queue_free()
   houses[i][j]={"node":make_house(i,j,v.era),"era":v.era}
  else:
   houses[i].append({"node":make_house(i,j,v.era),"era":v.era})
 rebuild_roads()

func original_creature(parent:Node3D,a:Dictionary)->Dictionary:
 var skin=Color("67ac97") if a.clan==0 else Color("c89c62")
 skin=skin.lerp(Color("d0dcb3"),float(a.genes[2])*.24)
 var body=Node3D.new()
 parent.add_child(body)
 sphere(body,skin,Vector3(0,.70,0),Vector3(.67,.80,.53))
 sphere(body,skin.lightened(.07),Vector3(0,1.24,.025),Vector3(.77,.70,.65))
 sphere(body,skin.lightened(.25),Vector3(0,.77,.245),Vector3(.41,.45,.12))
 sphere(body,Color("d5ae78"),Vector3(0,.50,0),Vector3(.66,.15,.54))
 var arms=[]
 var legs=[]
 for side in [-1,1]:
  var ear=sphere(body,skin.darkened(.08),Vector3(side*.39,1.42,.0),Vector3(.24,.38,.18))
  ear.rotation.z=side*-.56
  sphere(body,skin.lightened(.25),Vector3(side*.39,1.43,.083),Vector3(.11,.22,.05)).rotation.z=side*-.56
  sphere(body,Color("f2e6c9"),Vector3(side*.18,1.30,.29),Vector3(.25,.28,.15))
  sphere(body,Color("8b673d"),Vector3(side*.18,1.30,.36),Vector3(.16,.19,.07))
  sphere(body,Color("263b3a"),Vector3(side*.18,1.30,.397),Vector3(.107,.139,.045))
  sphere(body,Color("fff9e2"),Vector3(side*.18-.035,1.35,.42),Vector3(.047,.047,.024))
  var arm=Node3D.new()
  body.add_child(arm)
  arm.position=Vector3(side*.34,.98,.0)
  sphere(arm,skin,Vector3(side*.04,-.22,0),Vector3(.22,.45,.24))
  sphere(arm,skin.lightened(.08),Vector3(side*.04,-.42,.0),Vector3(.23,.19,.23))
  arms.append(arm)
  var leg=Node3D.new()
  body.add_child(leg)
  leg.position=Vector3(side*.18,.43,0)
  sphere(leg,skin.darkened(.08),Vector3(0,-.17,0),Vector3(.24,.35,.27))
  sphere(leg,skin,Vector3(0,-.32,.08),Vector3(.27,.16,.36))
  legs.append(leg)
 sphere(body,skin.darkened(.12),Vector3(0,1.13,.345),Vector3(.12,.065,.04))
 for j in range(3):
  sphere(body,Color("dceab0"),Vector3((j-1)*.10,1.55,.20),Vector3(.06,.08,.035),.5)
 return {"body":body,"arms":arms,"legs":legs}

func create_actor(a:Dictionary):
 if actors.has(a.id):return
 var parent=Node3D.new()
 people_root.add_child(parent)
 parent.position=random_near(centers[a.clan],6.5)
 var visual=asset(parent,"creature",int(a.clan)*4+mini(3,int(float(a.genes[2])*4)),Vector3.ZERO,1.0)
 var rig={}
 if visual==null:
  rig=original_creature(parent,a)
  rig.body.scale=Vector3.ONE*.62
 else:
  start_animation(visual,["walk","run","idle"])
  rig={"body":visual,"arms":[],"legs":[]}
 actors[a.id]={"node":parent,"body":rig.body,"arms":rig.arms,"legs":rig.legs,"target":random_near(centers[a.clan],7),"phase":rng.randf()*TAU}
 actors[a.id]["animation"]=animation_player(visual) if visual!=null else null
 actors[a.id]["moving"]=true
 parent.scale=Vector3.ONE*clampf(.5+a.age/26,.5,1)
 var name_tag=Label3D.new()
 parent.add_child(name_tag)
 name_tag.position.y=1.30
 name_tag.text=a.name
 name_tag.font_size=28
 name_tag.outline_size=5
 name_tag.pixel_size=.007
 name_tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 name_tag.hide()
 activity_labels[a.id]=name_tag

func apply_changes():
 for e in sim.changes:
  match e.kind:
   "birth":
    var a=sim.find(int(e.id))
    if not a.is_empty():create_actor(a)
   "death":
    if actors.has(e.id):
     var n=actors[e.id].node
     spark(n.position+Vector3(0,.6,0),Color("b8dad0"),.55)
     n.queue_free()
     actors.erase(e.id)
     activity_labels.erase(e.id)
    if selected==e.id:selected=-1
   "house","era":
    sync_houses(int(e.clan))
    rebuild_farms()
   "trade":spawn_caravan(int(e.clan))
   "project":rebuild_civic()
   "migration":
    var a=sim.find(int(e.id))
    if not a.is_empty() and actors.has(a.id):
     actors[a.id].target=random_near(centers[a.clan],5)
     actors[a.id].activity_day=-1
 sim.changes.clear()

func step_day():
 var old_tech=sim.discoveries.size()
 var previous_projects=sim.projects_completed
 var previous_crises=sim.crises_seen
 sim.daily()
 apply_changes()
 if sim.crises_seen>previous_crises:
  notify_event("CAMBIAMENTO NEL MONDO",sim.events[0])
 elif sim.discoveries.size()>old_tech:
  var last=sim.discoveries.back()
  notify_event("NUOVA SCOPERTA",Sim.CLANS[last.clan]+" · "+last.name)
 elif sim.projects_completed>previous_projects:
  notify_event("NUOVA OPERA CIVILE",sim.events[0])
 elif sim.day%25==0 and not sim.signals.is_empty():
  notify_event("SEGNALE DAL MONDO",str(sim.signals[0].text))
 if sim.ended!="" and show_ending:
  show_ending=false
  speed=0
  var dlg=AcceptDialog.new()
  dlg.title="EPILOGO"
  dlg.dialog_text=sim.ended+"\n\nIl tuo universo può continuare in modalità libera."
  hud.add_child(dlg)
  dlg.popup_centered(Vector2i(530,170))
 if sim.day%15==0 and autosave_enabled and not test_mode:
  save_path("user://genesis47_auto.json",false)
  last_auto_day=sim.day
 refresh()

func update_camera():
 if camera==null:return
 focus.y=maxf(height_at(focus.x,focus.z),SEA)+.8
 camera.position=focus+Vector3(sin(azimuth)*cos(pitch),sin(pitch),cos(azimuth)*cos(pitch))*distance
 camera.look_at(focus,Vector3.UP)

func _process(delta:float):
 if camera==null or centers.size()!=2 or test_mode:return
 visual_time+=delta
 ai_cooldown=maxf(0,ai_cooldown-delta)
 if speed>0 and portable_ai and ai_autonomy and not ai_busy and sim.day>=12 and sim.day-last_ai_day>=12 and ai_cooldown<=0:
  ask_autonomous()
 if toast_time>0:
  toast_time-=delta
  if toast_time<=0 and is_instance_valid(toast_panel):toast_panel.hide()
 var keyboard_ok=not (input.has_focus() or model.has_focus())
 var mov=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if keyboard_ok and mov.length()>0:
  following=false
  var right=Vector3(cos(azimuth),0,-sin(azimuth))
  var back=Vector3(sin(azimuth),0,cos(azimuth))
  focus+=(right*mov.x+back*mov.y)*delta*distance*.40
  focus.x=clampf(focus.x,-50,50)
  focus.z=clampf(focus.z,-50,50)
  update_camera()
 if speed>0:
  tick+=minf(delta,.1)*speed
  var loops=0
  while tick>=1.7 and loops<8 and speed>0:
   tick-=1.7
   step_day()
   loops+=1
  for a in sim.people:
   if not actors.has(a.id):continue
   var r=actors[a.id]
   var n:Node3D=r.node
   var step=delta*minf(speed,5.0)
   var reached=Vector2(n.position.x-r.target.x,n.position.z-r.target.z).length()<.45
   var resting=str(a.get("activity","Esplora")) in ["Riposa","Studia","Cerca cibo","Incontra la famiglia"]
   if (reached and not resting) or int(r.get("activity_day",-1))!=sim.day:
    r.activity_day=sim.day
    var activity=str(a.get("activity","Esplora"))
    if activity=="Riposa":
     r.target=house_location(a.clan, a.id%maxi(1,houses[a.clan].size()))
    elif activity=="Incontra la famiglia" and actors.has(a.partner):
     r.target=actors[a.partner].node.position
    elif activity=="Cerca cibo" and not farm_points[a.clan].is_empty():
     r.target=farm_points[a.clan][int(a.id)%farm_points[a.clan].size()]
    elif activity=="Studia":
     r.target=random_near(centers[a.clan],2.2)
    else:
     var radius=5.0 if activity=="Cerca cibo" else 11.0
     r.target=random_near(centers[a.clan],radius)
   if activity_labels.has(a.id):
    var tag:Label3D=activity_labels[a.id]
    tag.visible=(show_labels or a.id==selected) and distance<36
    tag.text=a.name+" · "+str(a.get("activity","Esplora"))
   var direction:Vector3=r.target-n.position
   direction.y=0
   var moving=direction.length()>.35
   if r.get("moving",true)!=moving:
    r.moving=moving
    if is_instance_valid(r.get("animation")):choose_motion(r.animation,moving)
   if moving:
    var p=n.position+direction.normalized()*minf(step*.92,direction.length())
    for home in houses[a.clan]:
     var away=p-home.node.position
     away.y=0
     if away.length()<1.12 and away.length()>.001:p+=away.normalized()*.12
    p.y=height_at(p.x,p.z)
    if p.y>SEA+.12:
     n.position=p
     n.rotation.y=lerp_angle(n.rotation.y,atan2(direction.x,direction.z),minf(delta*7,1))
    else:r.target=centers[a.clan]
   r.phase+=step*7 if moving else delta*1.8
   if not r.legs.is_empty():
    r.body.position.y=absf(sin(r.phase))*(.05 if moving else .015)
    for i in range(2):
     r.legs[i].rotation.x=sin(r.phase+i*PI)*(.46 if moving else .025)
     r.arms[i].rotation.x=sin(r.phase+i*PI+PI)*(.32 if moving else .045)
   n.scale=Vector3.ONE*clampf(.50+a.age/26,.5,1)
  for animal in animals:
   var n:Node3D=animal.node
   if n.position.distance_to(animal.target)<.32:animal.target=random_near(animal.center,15)
   var dir:Vector3=animal.target-n.position
   dir.y=0
   if dir.length()>.05:
    var p=n.position+dir.normalized()*delta*.42
    p.y=height_at(p.x,p.z)
    if p.y>SEA+.2:
     n.position=p
     n.rotation.y=lerp_angle(n.rotation.y,atan2(dir.x,dir.z),minf(delta*4,1))
    else:animal.target=animal.center
  var phase=fmod(float(sim.day)+tick/1.7,16.0)/16.0
  var daylight=clampf(.66+.43*sin(phase*TAU+.8),.20,1)
  sun.light_energy=.14+daylight*.83
  sun.light_color=Color("a4baff").lerp(Color("ffe7bd"),daylight)
  sun.rotation_degrees=Vector3(-22-daylight*38,-37+sin(phase*TAU)*24,0)
  env.ambient_light_color=Color("a4bdd8").lerp(Color("e2e7d3"),daylight)
  env.ambient_light_energy=.12+daylight*.31
  sky_material.sky_top_color=Color("172b51").lerp(Color("4d86b4"),daylight)
  sky_material.sky_horizon_color=Color("495478").lerp(Color("cfdfd4"),daylight)
  env.fog_light_color=Color("374f68").lerp(Color("afc8cf"),daylight)
 if actors.has(selected):
  var n:Node3D=actors[selected].node
  cursor.show()
  cursor.position=n.position+Vector3(0,.045,0)
  if following:
   focus=focus.lerp(n.position,clampf(delta*6,0,1))
   update_camera()
 else:cursor.hide()
 if is_instance_valid(precipitation):
  precipitation.position=Vector3(focus.x, maxf(focus.y+10,14),focus.z)
  var snowy=sim.weather_name=="Neve"
  if snowy and precipitation.mesh!=snow_mesh:
   precipitation.mesh=snow_mesh
   precipitation.gravity=Vector3(0,-1.0,0)
   precipitation.initial_velocity_min=.4
   precipitation.initial_velocity_max=1.2
   precipitation.lifetime=5
  elif not snowy and precipitation.mesh!=rain_mesh:
   precipitation.mesh=rain_mesh
   precipitation.gravity=Vector3(0,-12,0)
   precipitation.initial_velocity_min=7
   precipitation.initial_velocity_max=10
   precipitation.lifetime=1.65
  precipitation.emitting=sim.weather_name in ["Pioggia","Neve"] and speed>0 and distance<65
 update_caravans(delta)
 update_clouds(delta)
 for rotor in civic_spinners:
  if is_instance_valid(rotor):rotor.rotation.y+=delta*.38
 if is_instance_valid(hover_ring):
  hover_ring.visible=false
  if power!="Osserva" and not photo_mode and (get_viewport().gui_get_hovered_control()==null or get_viewport().gui_get_hovered_control()==hud):
   var hp=ground_at(get_viewport().get_mouse_position())
   if hp.y>SEA-.5:
    hover_ring.position=hp+Vector3.UP*.12
    hover_ring.visible=true
 update_effects(delta)

func _unhandled_input(event:InputEvent):
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_F10:toggle_photo()
  if event.keycode==KEY_F1:show_help()
  if event.keycode==KEY_TAB:toggle_compact()
  if event.keycode==KEY_HOME:
   following=false
   focus=centers[0]
   distance=27
   pitch=.72
   update_camera()
  if event.keycode==KEY_F5:save_game(true)
  if event.keycode==KEY_F9:load_game()
  if event.keycode==KEY_SPACE:
   if speed>0:
    previous_speed=speed
    speed=0
   else:speed=previous_speed
   update_time_buttons()
  if event.keycode==KEY_ESCAPE:power="Osserva";following=false;refresh();populate_powers(power_category.selected)
 if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
  azimuth-=event.relative.x*.006
  pitch=clampf(pitch+event.relative.y*.005,.24,1.48)
  update_camera()
 if event is InputEventMouseButton and event.pressed:
  if event.button_index==MOUSE_BUTTON_WHEEL_UP:
   distance=maxf(3.7,distance*.86)
   update_camera()
  elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
   distance=minf(125,distance*1.16)
   update_camera()
  elif event.button_index==MOUSE_BUTTON_LEFT:
   if power=="Osserva":select_at(event.position)
   else:
    var p=ground_at(event.position)
    if p.y>SEA-.5 and absf(p.x)<51 and absf(p.z)<51:divine(p)

func ground_at(mouse:Vector2)->Vector3:
 var origin=camera.project_ray_origin(mouse)
 var dir=camera.project_ray_normal(mouse)
 for i in range(600):
  var p=origin+dir*i*.35
  if p.y<=height_at(p.x,p.z):return ground(p.x,p.z)
 return Vector3(0,-100,0)

func select_at(mouse:Vector2):
 var best=28.0
 selected=-1
 following=false
 for id in actors:
  var p:Vector3=actors[id].node.position+Vector3(0,.55,0)
  if camera.is_position_behind(p):continue
  var dist=camera.unproject_position(p).distance_to(mouse)
  if dist<best:
   best=dist
   selected=id
 refresh()

func spark(p:Vector3,c:Color,scale_value=1.0):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p
 var ring=TorusMesh.new()
 ring.inner_radius=.80
 ring.outer_radius=.92
 piece(n,ring,c,Vector3(0,.12,0),Vector3.ONE*scale_value,1.2)
 for i in range(12):
  var a=i*TAU/12
  var q=sphere(n,c,Vector3(cos(a)*.45,.35,sin(a)*.45),Vector3.ONE*.12,1.1)
  q.set_meta("velocity",Vector3(cos(a)*1.9,rng.randf_range(1,3),sin(a)*1.9)*scale_value)
 effects.append({"node":n,"life":1.7,"max":1.7,"kind":"spark","scale":scale_value})

func meteor(p:Vector3):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p+Vector3(-12,24,-6)
 sphere(n,Color("f8a052"),Vector3.ZERO,Vector3.ONE*1.5,1.4)
 sphere(n,Color("ffe4a2"),Vector3(.1,.05,.03),Vector3.ONE*.95,1.9)
 for i in range(8):
  sphere(n,Color("ef7c42").lerp(Color("ffd48b"),float(i)/8),Vector3(-.3*i,.62*i,-.15*i),Vector3.ONE*(1.05-float(i)*.095),1.1)
 effects.append({"node":n,"life":1.1,"max":1.1,"kind":"meteor","dest":p,"from":n.position})

func wave(p:Vector3):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p+Vector3(0,.4,0)
 for i in range(17):
  var a=i*TAU/17
  var q=sphere(n,Color("6cc9d3"),Vector3(cos(a),.25,sin(a))*1.1,Vector3(1.6,1.1,1.6),.12)
  q.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 effects.append({"node":n,"life":2.6,"max":2.6,"kind":"wave","scale":1.0})

func lightning(p:Vector3):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p
 var mesh=ImmediateMesh.new()
 mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP,material(Color("e1f5ff"),.4,2.0))
 for i in range(14):
  mesh.surface_add_vertex(Vector3(rng.randf_range(-.7,.7) if i>0 else 0,float(i)*1.5,rng.randf_range(-.5,.5) if i>0 else 0))
 mesh.surface_end()
 var mi=MeshInstance3D.new()
 mi.mesh=mesh
 n.add_child(mi)
 var l=OmniLight3D.new()
 l.light_color=Color("b5e4ff")
 l.light_energy=8
 l.omni_range=12
 n.add_child(l)
 l.position.y=1.4
 effects.append({"node":n,"life":.35,"max":.35,"kind":"bolt"})
 spark(p,Color("cceeff"),1.8)

func update_effects(delta:float):
 for e in effects.duplicate():
  if not is_instance_valid(e.node):
   effects.erase(e)
   continue
  e.life-=delta
  var frac=clampf(1.0-e.life/e.max,0,1)
  if e.kind=="meteor":
   e.node.position=e.from.lerp(e.dest,frac*frac)
   if e.life<=0:
    spark(e.dest,Color("f6a14e"),2.8)
    impact_cloud(e.dest)
  elif e.kind=="wave":
   e.node.scale=Vector3(1+frac*10,1+sin(frac*PI)*2.2,1+frac*10)
  elif e.kind=="impact":
   for child in e.node.get_children():
    if child is OmniLight3D:child.light_energy=6*(1-frac)
    elif child is MeshInstance3D:child.scale=Vector3.ONE*(.3+frac*8)
  elif e.kind=="spark":
   for child in e.node.get_children():
    if child.has_meta("velocity"):
     var velocity:Vector3=child.get_meta("velocity")
     child.position+=velocity*delta
     child.set_meta("velocity",velocity-Vector3(0,3.8,0)*delta)
    else:child.scale=Vector3.ONE*float(e.scale)*(1+frac*4.5)
  if e.life<=0:
   e.node.queue_free()
   effects.erase(e)

func alter_ground(p:Vector3,amount:float,r:float):
 if deformation.size()>=48:deformation.pop_front()
 deformation.append({"x":p.x,"z":p.z,"h":amount,"r":r})
 make_terrain()
 for collection in [scenery,villages_root,people_root,animals_root,civic_root,farms_root]:
  for n in collection.get_children():
   if n is Node3D:n.position.y=height_at(n.position.x,n.position.z)
 for i in range(centers.size()):centers[i]=ground(centers[i].x,centers[i].z)
 rebuild_roads()

func divine(p:Vector3):
 if power=="Osserva":return
 var cost=18.0 if power in ["Meteorite","Tsunami","Vulcano","Resurrezione","Montagna","Lago"] else 9.0
 if power in ["Vita","Nuova specie","Resurrezione"] and sim.people.size()>=Sim.LIMIT:
  hint.text="Limite della popolazione raggiunto."
  return
 if power=="Resurrezione" and sim.dead.is_empty():
  hint.text="Nessun abitante da resuscitare."
  return
 if sim.energy<cost and not unlimited:
  hint.text="Energia insufficiente."
  return
 if not unlimited:sim.energy-=cost
 sim.miracles+=1
 var clan=0 if p.distance_to(centers[0])<p.distance_to(centers[1]) else 1
 var v=sim.villages[clan]
 var color=Color("f5d991")
 var near=[]
 for a in sim.people:
  if actors.has(a.id) and actors[a.id].node.position.distance_to(p)<6:near.append(a)
 match power:
  "Vita":
   var a=sim.birth(clan,[])
   if not a.is_empty():
    create_actor(a)
    actors[a.id].node.position=p
  "Foresta":
   for i in range(8):
    if planted.size()>=400:break
    var place= random_near(p,3)
    var h=rng.randf_range(2.1,4.2)
    make_tree(place,h,i)
    planted.append({"x":place.x,"z":place.z,"h":h,"i":i})
   v.wood+=24
  "Provviste":v.food=minf(850,v.food+100)
  "Guarigione":
   for a in near:
    a.health=100
    a.sick=0
    a.mood=minf(100,a.mood+20)
    a.faith=minf(100,a.faith+12)
    sim.remember(a,"Il Creatore mi ha guarito.")
  "Meteorite":
   color=Color("eb713b")
   meteor(p)
   for a in near:
    a.health-=80
    if a.health<=0:sim.die(a,"meteorite")
   v.food=maxf(0,v.food-60)
   if v.houses>2:v.houses-=1;sync_houses(clan)
   alter_ground(p,-1.5,4)
  "Conoscenza":v.knowledge+=65
  "Pace":sim.peace=minf(100,sim.peace+22)
  "Mutazione":
   for a in near:
    a.genes[0]=clampf(a.genes[0]+.14,0,1)
    a.genes[2]=clampf(a.genes[2]+rng.randf_range(-.25,.25),0,1)
    sim.remember(a,"Una mutazione ha cambiato le mie capacità.")
  "Pioggia":
   v.food=minf(850,v.food+42)
   color=Color("8fcddb")
   sim.weather_name="Pioggia"
   wave(p)
  "Conflitto":sim.peace=maxf(0,sim.peace-30)
  "Fede":
   v.faith=minf(100,v.faith+18)
   for a in near:a.faith=minf(100,a.faith+18)
  "Fulmine":
   lightning(p)
   color=Color("ceebff")
   for a in near:a.health=maxf(1,a.health-35)
  "Tsunami":
   wave(p)
   color=Color("7fc9dd")
   for a in near:a.health=maxf(1,a.health-50)
   v.food*=.55
  "Vulcano":
   alter_ground(p,5,7)
   meteor(p)
   impact_cloud(p)
   color=Color("e67f43")
   v.food*=.7
   for a in near:a.health=maxf(1,a.health-65)
  "Resurrezione":
   if not sim.dead.is_empty():
    var old=sim.dead.pop_back()
    var a=sim.birth(clan,[])
    if not a.is_empty():
     a.name=old.name+" Rinato"
     a.gen=int(old.gen)
     sim.remember(a,"Sono tornato dalla morte.")
     create_actor(a)
     actors[a.id].node.position=p
  "Montagna":alter_ground(p,3.8,6)
  "Lago":alter_ground(p,-4.8,6)
  "Profeta":
   for a in near:
    a.role="Profeta"
    a.prophet=true
    a.faith=100
    sim.remember(a,"Il Creatore mi ha affidato una visione.")
   v.faith=minf(100,v.faith+24)
  "Nuova specie":
   var a=sim.birth(clan,[])
   if not a.is_empty():
    a.genes=[rng.randf_range(.5,.95),rng.randf_range(.2,.9),rng.randf(),rng.randf()]
    a.name="Evo "+str(a.id)
    create_actor(a)
    actors[a.id].node.position=p
  "Carestia":v.food*=.22
 spark(p,color,1.5)
 if not test_mode:play_event_sound(power in ["Meteorite","Fulmine","Vulcano","Tsunami"])
 sim.log_event("Intervento divino: "+power+" su "+Sim.CLANS[clan]+".")
 apply_changes()
 refresh()

func panel(parent:Control,r:Rect2,opacity=.94)->PanelContainer:
 var n=PanelContainer.new()
 parent.add_child(n)
 n.position=r.position
 n.size=r.size
 var s=StyleBoxFlat.new()
 s.bg_color=Color(.055,.115,.125,opacity)
 s.border_color=Color("42665f")
 s.set_border_width_all(1)
 s.set_corner_radius_all(10)
 s.content_margin_left=13
 s.content_margin_right=13
 s.content_margin_top=10
 s.content_margin_bottom=10
 n.add_theme_stylebox_override("panel",s)
 return n

func text_label(parent:Node,txt:String,size_value=16)->Label:
 var l=Label.new()
 l.text=txt
 l.add_theme_font_size_override("font_size",size_value)
 l.add_theme_color_override("font_color",Color("f1e8d6"))
 parent.add_child(l)
 return l

func button(parent:Node,txt:String,action:Callable)->Button:
 var b=Button.new()
 b.text=txt
 b.custom_minimum_size=Vector2(0,33)
 parent.add_child(b)
 b.pressed.connect(action)
 return b

func rich(parent:Node,h:float)->RichTextLabel:
 var l=RichTextLabel.new()
 l.custom_minimum_size=Vector2(0,h)
 l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 l.add_theme_font_size_override("normal_font_size",15)
 parent.add_child(l)
 return l

func setup_ui():
 var layer=CanvasLayer.new()
 add_child(layer)
 hud=Control.new()
 layer.add_child(hud)
 hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var theme=Theme.new()
 theme.default_font_size=14
 theme.set_color("font_color","Button",Color("e5f0e8"))
 for state in ["normal","hover","pressed","focus","disabled"]:
  var s=StyleBoxFlat.new()
  s.bg_color=Color("26443f") if state=="normal" else Color("3f6660") if state!="disabled" else Color("1d3331")
  s.set_corner_radius_all(5)
  s.content_margin_left=9
  s.content_margin_right=9
  s.content_margin_top=5
  s.content_margin_bottom=5
  theme.set_stylebox(state,"Button",s)
 hud.theme=theme
 var header=panel(hud,Rect2(14,12,1412,80),.91)
 var col=VBoxContainer.new()
 header.add_child(col)
 var row=HBoxContainer.new()
 col.add_child(row)
 title=text_label(row,"GENESIS 47   /   P R O J E C T   G O D",22)
 var sp=Control.new()
 row.add_child(sp)
 sp.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button(row,"Guida",show_help)
 button(row,"Vista",toggle_compact)
 button(row,"Opzioni",show_options)
 button(row,"Nuovo",open_welcome)
 selected_slot=OptionButton.new()
 for i in range(3):selected_slot.add_item("Slot "+str(i+1))
 selected_slot.item_selected.connect(func(i):slot=i)
 row.add_child(selected_slot)
 button(row,"Salva",func():save_game(true))
 button(row,"Carica",load_game)
 button(row,"Foto",toggle_photo)
 button(row,"Audio",func():audio.stream_paused=not audio.stream_paused;store_settings())
 top=text_label(col,"",16)
 var left=panel(hud,Rect2(14,104,190,650),.88)
 left_panel=left
 var lv=VBoxContainer.new()
 left.add_child(lv)
 text_label(lv,"POTERI DIVINI",17)
 power_label=text_label(lv,"Osserva",14)
 power_label.modulate=Color("a7d9bc")
 power_category=OptionButton.new()
 for label in ["Vita e natura","Civiltà e mente","Catastrofi","Terraformazione"]:power_category.add_item(label)
 lv.add_child(power_category)
 power_category.item_selected.connect(func(i):populate_powers(i))
 var scroll=ScrollContainer.new()
 scroll.custom_minimum_size=Vector2(155,285)
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 lv.add_child(scroll)
 power_grid=VBoxContainer.new()
 scroll.add_child(power_grid)
 power_grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 populate_powers(0)
 text_label(lv,"MAPPA DEL MONDO",13)
 map_view=preload("res://scripts/minimap.gd").new()
 map_view.world=self
 map_view.custom_minimum_size=Vector2(155,135)
 lv.add_child(map_view)
 var infinite=CheckButton.new()
 infinite.text="Energia infinita"
 infinite.toggled.connect(func(on):unlimited=on)
 lv.add_child(infinite)
 var right=panel(hud,Rect2(1107,104,319,650),.88)
 right_panel=right
 var rv=VBoxContainer.new()
 right.add_child(rv)
 text_label(rv,"VITA  /  CIVILTÀ",18)
 status_bar=ProgressBar.new()
 status_bar.custom_minimum_size.y=12
 status_bar.show_percentage=false
 status_bar.max_value=100
 var bg=StyleBoxFlat.new()
 bg.bg_color=Color("263b3a")
 bg.set_corner_radius_all(5)
 status_bar.add_theme_stylebox_override("background",bg)
 health_fill=StyleBoxFlat.new()
 health_fill.bg_color=Color("83c8a4")
 health_fill.set_corner_radius_all(5)
 status_bar.add_theme_stylebox_override("fill",health_fill)
 rv.add_child(status_bar)
 stats_bar=text_label(rv,"",13)
 stats_bar.modulate=Color("a7d9bc")
 selected_status=text_label(rv,"Osservazione del mondo",13)
 selected_status.modulate=Color("a7d9bc")
 details=rich(rv,240)
 var line=HBoxContainer.new()
 rv.add_child(line)
 button(line,"Segui",func():
  if actors.has(selected):
   following=true
   focus=actors[selected].node.position
   distance=3.6
   pitch=.36
   update_camera())
 button(line,"Casuale",func():
  if not sim.people.is_empty():
   selected=sim.people[rng.randi_range(0,sim.people.size()-1)].id
   refresh())
 button(line,"Preferito",func():
  var a=sim.find(selected)
  if not a.is_empty():a.favorite=not a.favorite;refresh())
 var line2=HBoxContainer.new()
 rv.add_child(line2)
 button(line2,"Atlante",show_atlas)
 signals_button=button(line2,"Segnali",show_signals)
 button(line2,"Scoperte",show_tech)
 button(rv,"Progetti delle civiltà",show_projects)
 var extra=HBoxContainer.new()
 rv.add_child(extra)
 button(extra,"Traguardi",show_achievements)
 button(extra,"Statistiche",show_history)
 button(extra,"Nomi",func():show_labels=not show_labels)
 text_label(rv,"PARLA CON LA VITA",15)
 input=LineEdit.new()
 input.placeholder_text="Scrivi al tuo universo..."
 input.max_length=400
 rv.add_child(input)
 button(rv,"Invia messaggio",send_message)
 input.text_submitted.connect(func(_message):send_message())
 model=LineEdit.new()
 model.text="qwen2.5:1.5b"
 model.placeholder_text="Modello Ollama locale"
 rv.add_child(model)
 model.visible=not portable_ai
 ai_button=button(rv,"Risposta generativa" if portable_ai else "Risposta generativa (Ollama)",ask_ai)
 if portable_ai:
  var autonomy=CheckButton.new()
  autonomy.text="Iniziativa autonoma AI"
  autonomy.button_pressed=ai_autonomy
  autonomy.toggled.connect(func(on):ai_autonomy=on;store_settings())
  rv.add_child(autonomy)
 var bottom=panel(hud,Rect2(14,769,1412,117),.91)
 bottom_panel=bottom
 var bv=VBoxContainer.new()
 bottom.add_child(bv)
 var controls=HBoxContainer.new()
 bv.add_child(controls)
 text_label(controls,"TEMPO",15)
 for s in [0.0,1.0,3.0,12.0,60.0]:
  var tb=button(controls,"Pausa" if s==0 else str(int(s))+"×",func():speed=s;update_time_buttons())
  tb.toggle_mode=true
  tb.set_meta("speed",s)
  time_buttons.append(tb)
 button(controls,"Mondo",func():following=false;focus=Vector3.ZERO;distance=91;pitch=.88;update_camera())
 for i in range(2):
  button(controls,Sim.CLANS[i],func():following=false;focus=centers[i];distance=24;pitch=.72;update_camera())
 hint=text_label(controls,"WASD · rotella · tasto destro · F10 foto",13)
 hint.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
 hint.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 objective=text_label(bv,"",14)
 chronicle=rich(bv,38)
 chronicle.scroll_following=false
 toast_panel=panel(hud,Rect2(430,104,570,64),.94)
 toast_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 toast_label=text_label(toast_panel,"",16)
 toast_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 toast_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 toast_panel.hide()

func toggle_photo():
 photo_mode=not photo_mode
 hud.visible=not photo_mode

func refresh():
 if top==null or sim.villages.size()!=2:return
 top.text="GIORNO %03d    ·    %d VIVENTI    ·    ENERGIA %d/100    ·    PACE %d%%    ·    %d SCOPERTE    ·    %d SCAMBI"%[sim.day,sim.people.size(),int(sim.energy),int(sim.peace),sim.discoveries.size(),sim.trades]
 top.text+="    ·    "+sim.season+" / "+sim.weather_name
 power_label.text=power
 if map_view!=null:map_view.queue_redraw()
 update_time_buttons()
 if signals_button!=null:
  var pending=sim.signals.filter(func(q):return not q.answered and not sim.find(int(q.id)).is_empty()).size()
  signals_button.text="Segnali "+str(pending) if pending>0 else "Segnali"
 var a=sim.find(selected)
 if selected_status!=null:selected_status.text="Osservazione del mondo" if a.is_empty() else str(a.get("activity","Esplora"))+" · "+("Malato" if int(a.get("sick",0))>0 else "In salute")
 if status_bar!=null:
  status_bar.value=sim.energy if a.is_empty() else float(a.health)
  health_fill.bg_color=Color("e1bc78") if a.is_empty() else Color("d7796c").lerp(Color("83c8a4"),float(a.health)/100)
  stats_bar.text="Energia divina · %d%%"%int(sim.energy) if a.is_empty() else "Salute · %d%%"%int(a.health)
 if a.is_empty():
  var lines=[]
  for i in range(2):
   var v=sim.villages[i]
   lines.append("%s  /  %s\n%d abitanti · %d edifici\nCibo %d · Legna %d\nFede %d%% · Scoperte %d/14\n%s\n%s"%[Sim.CLANS[i],Sim.ERAS[v.era],sim.count(i),v.houses,int(v.food),int(v.wood),int(v.faith),v.tech,v.government,v.belief])
   if int(v.project)>=0:lines.append("→ "+Sim.PROJECT_NAMES[int(v.project)]+" · "+str(int(v.progress))+"%")
  details.text="\n\n".join(lines)+"\n\nClicca una creatura per conoscerla."
 else:
  details.text=("%s%s\n%s · %s\nEtà %d · Generazione %d\nSalute %d%% · Fame %d%%\nUmore %d%% · Fede %d%%\nIntelletto %d%% · Empatia %d%%\nGenitori: %s · Partner: %s\nObiettivo: %s\n\nRICORDI\n%s"%["★ " if a.favorite else "",a.name,Sim.CLANS[a.clan],a.role,int(a.age),a.gen,int(a.health),int(a.hunger),int(a.mood),int(a.faith),int(a.genes[0]*100),int(a.genes[1]*100),family_names(a.parents),family_names([a.partner]),a.goal,"\n".join(a.memories)])
 objective.text=["ETERNITÀ  —  Nessun limite di durata.","ALLEANZA  —  Giorno 90 · pace 70% · entrambi i popoli nell'era Regni.","OLTRE IL CIELO  —  Giorno 100 · era Contatto.","ULTIMA SCINTILLA  —  Giorno 120 · almeno 24 sopravvissuti."][sim.mode]
 if not a.is_empty() and int(a.get("intention_until",0))>sim.day:details.text+="\n\nINTENZIONE AI: "+str(a.get("intention",""))+" · fino al giorno "+str(a.intention_until)
 if sim.mode==0:
  if sim.people.is_empty():objective.text="ETERNITÀ — Mondo disabitato. Usa Vita per ricominciare."
  elif sim.legacy_cycles>0:objective.text+="  ·  Cicli del futuro: "+str(sim.legacy_cycles)
 if sim.mode==0 and not sim.active_crisis.is_empty():
  objective.text=Sim.CRISIS_NAMES[int(sim.active_crisis.kind)]+" · "+Sim.CLANS[int(sim.active_crisis.clan)]+" · fino al giorno "+str(sim.active_crisis.until)
 if sim.ended!="":objective.text=sim.ended
 chronicle.text="\n".join(sim.events.slice(0,12))

func open_welcome():
 if welcome_open:return
 welcome_open=true
 speed=0
 var dlg=ConfirmationDialog.new()
 hud.add_child(dlg)
 dlg.title="GENESIS 47  /  Crea l'universo"
 dlg.ok_button_text="Crea il mondo"
 dlg.cancel_button_text="Continua"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 text_label(box,"Eternità: nessun finale obbligatorio, nemmeno dopo l’estinzione.",16)
 text_label(box,"Oppure scegli una sfida narrativa facoltativa.",14)
 var option=OptionButton.new()
 for s in ["Eternità — mondo infinito","L'alleanza — pace","Oltre il cielo — contatto","L'ultima scintilla — sopravvivenza"]:option.add_item(s)
 box.add_child(option)
 var seed_input=LineEdit.new()
 seed_input.text=str(rng.randi_range(1,999999))
 box.add_child(seed_input)
 text_label(box,"Seme del mondo · TAB interfaccia ridotta · F10 cinema",13)
 for i in range(3):
  if FileAccess.file_exists(SAVE_PREFIX+str(i)+".json") or FileAccess.file_exists(SAVE_PREFIX+str(i)+".json.bak"):
   button(box,"Riprendi slot "+str(i+1),func():welcome_open=false;world_started=true;slot=i;selected_slot.select(i);dlg.hide();load_game();dlg.queue_free())
 if FileAccess.file_exists("user://genesis47_auto.json") or FileAccess.file_exists("user://genesis47_auto.json.bak"):
  button(box,"Riprendi l’ultimo salvataggio automatico",func():welcome_open=false;world_started=true;dlg.hide();load_path("user://genesis47_auto.json");dlg.queue_free())
 dlg.confirmed.connect(func():
  welcome_open=false
  world_started=true
  deformation.clear()
  new_world(maxi(1,abs(int(seed_input.text))),option.selected)
  dlg.queue_free())
 dlg.canceled.connect(func():welcome_open=false;world_started=true;speed=1;update_time_buttons();dlg.queue_free())
 dlg.popup_centered(Vector2i(620,220))

func open_dialog(heading:String,content:String):
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title=heading
 var r=RichTextLabel.new()
 r.custom_minimum_size=Vector2(620,420)
 r.text=content
 dlg.add_child(r)
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(650,480))

func show_atlas():
 var dlg=AcceptDialog.new()
 atlas_window=dlg
 hud.add_child(dlg)
 dlg.title="ATLANTE DEGLI ABITANTI"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 var search=LineEdit.new()
 search.placeholder_text="Cerca nome, mestiere o popolo"
 box.add_child(search)
 var filter=CheckButton.new()
 filter.text="Solo preferiti"
 box.add_child(filter)
 var list=ItemList.new()
 list.custom_minimum_size=Vector2(575,315)
 box.add_child(list)
 var reload=func():
  list.clear()
  for a in sim.people:
   var line="%s%s  ·  %s  ·  %s  ·  G%d"%["★ " if a.favorite else "",a.name,Sim.CLANS[a.clan],a.role,a.gen]
   if filter.button_pressed and not a.favorite:continue
   if not line.to_lower().contains(search.text.to_lower()):continue
   var idx=list.add_item(line)
   list.set_item_metadata(idx,a.id)
 reload.call()
 search.text_changed.connect(func(_v):reload.call())
 filter.toggled.connect(func(_v):reload.call())
 var jump=func():
  var ids=list.get_selected_items()
  if ids.is_empty():return
  selected=int(list.get_item_metadata(ids[0]))
  if actors.has(selected):
   following=true
   focus=actors[selected].node.position
   distance=4.5
   pitch=.45
   update_camera()
  refresh()
  dlg.hide()
  dlg.queue_free()
 list.item_activated.connect(func(_i):jump.call())
 button(box,"Osserva l'abitante selezionato",jump)
 button(box,"Archivio dei defunti",func():
  var lines=[]
  for a in sim.dead:lines.append("%s · G%d · giorno %d · %s"%[a.name,a.gen,a.day,a.reason])
  open_dialog("ARCHIVIO DEI DEFUNTI","\n".join(lines) if not lines.is_empty() else "Nessun defunto."))
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(620,475))

func show_signals():
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title="SEGNALI DAL MONDO"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 var pending=[]
 for i in range(sim.signals.size()):
  var q=sim.signals[i]
  if not q.answered and not sim.find(int(q.id)).is_empty():pending.append(i)
 if pending.is_empty():
  text_label(box,"Nessuna domanda in attesa. Lascia evolvere il mondo.",16)
 else:
  var idx=int(pending[0])
  var q=sim.signals[idx]
  var a=sim.find(int(q.id))
  text_label(box,a.name+" · "+Sim.CLANS[a.clan]+" · giorno "+str(q.day),16)
  var question=text_label(box,q.text,21)
  question.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  question.custom_minimum_size.x=520
  var choices=["Proteggi e invita alla pace","Incoraggia la scienza","Rispetta il libero arbitrio","Imponi la tua autorità"]
  for i in range(4):
   button(box,choices[i],func():
    var stable_idx=sim.signals.find(q)
    if stable_idx>=0:sim.answer_signal(stable_idx,i)
    selected=int(q.id)
    dlg.hide()
    dlg.queue_free()
    refresh())
  button(box,"Trova la creatura",func():
   selected=int(q.id)
   if actors.has(selected):
    following=true
    distance=3.8
    pitch=.45
    focus=actors[selected].node.position
    update_camera()
   dlg.hide()
   dlg.queue_free()
   refresh())
 text_label(box,"Domande aperte: "+str(pending.size())+" · Decisioni prese: "+str(sim.decisions.size()),13)
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(560,330))

func show_tech():
 var lines=[]
 for t in sim.discoveries:lines.append("G%d · %s · %s"%[t.day,Sim.CLANS[t.clan],t.name])
 open_dialog("ENCICLOPEDIA DELLE SCOPERTE","\n".join(lines) if not lines.is_empty() else "L'intelligenza deve ancora svilupparsi.")

func send_message():
 var msg=input.text.strip_edges()
 if msg=="":return
 var a=sim.find(selected)
 if a.is_empty():
  sim.log_event("Il Creatore: "+msg)
  for v in sim.villages:v.faith=clampf(v.faith+2,0,100)
 else:sim.apply_reply(a,msg)
 input.clear()
 refresh()

func ask_ai():
 if ai_busy:
  hint.text="AI occupata: attendi la risposta."
  return
 var a=sim.find(selected)
 if a.is_empty():
  hint.text="Seleziona una creatura."
  return
 var prompt="Interpreta un personaggio immaginario di GENESIS 47. Nome %s, popolo %s, età %d, fede %d, obiettivo %s. Ricordi %s. Messaggio del Creatore: %s. Rispondi in italiano in prima persona, massimo 45 parole. Puoi dissentire. Non fingere di agire fuori dal gioco."%[a.name,Sim.CLANS[a.clan],int(a.age),int(a.faith),a.goal,"; ".join(a.memories),input.text]
 var payload={"model":model.text.strip_edges(),"prompt":prompt,"stream":false,"options":{"num_predict":100}}
 var endpoint="http://127.0.0.1:11434/api/generate"
 if portable_ai:
  endpoint="http://127.0.0.1:17847/v1/chat/completions"
  payload={"model":"genesis-local","messages":[{"role":"system","content":"Interpreta una creatura immaginaria del gioco, rispondi brevemente in italiano e non uscire dal personaggio."},{"role":"user","content":prompt}],"stream":false,"max_tokens":100,"temperature":.72}
 var err=request.request(endpoint,["Content-Type: application/json"],HTTPClient.METHOD_POST,JSON.stringify(payload))
 if err==OK:
  request_target=a.id
  ai_busy=true
  ai_is_autonomous=false
  if ai_button!=null:ai_button.disabled=true
  sim.remember(a,"Il Creatore: "+input.text.left(300))
  hint.text="AI locale in elaborazione..."
 else:hint.text="AI locale occupata o assente."

func ai_response(result:int,code:int,_headers:PackedStringArray,body:PackedByteArray):
 var autonomous=ai_is_autonomous
 ai_busy=false
 ai_is_autonomous=false
 if ai_button!=null:ai_button.disabled=false
 if result!=HTTPRequest.RESULT_SUCCESS or code!=200:
  hint.text="AI locale non disponibile. Usa il dialogo offline o avvia il gioco con AI portatile."
  return
 var data=JSON.parse_string(body.get_string_from_utf8())
 var a=sim.find(request_target)
 if data is Dictionary and not a.is_empty():
  var reply=str(data.get("response","")).strip_edges().left(650)
  if portable_ai:
   var choices=data.get("choices",[])
   if not choices.is_empty():reply=str(choices[0].get("message",{}).get("content","")).strip_edges().left(650)
  if reply!="":
   ai_reply_received=true
   if autonomous:
    var intent=reply.split("|",true,1)[0].strip_edges().to_upper()
    if not intent in ["RICERCA","CIBO","CURA","PACE","ESPLORA"]:
     hint.text="La creatura non ha formulato una decisione valida."
     return
    var thought=reply.split("|",true,1)[1].strip_edges() if reply.contains("|") else "Ho scelto una nuova priorità."
    if sim.adopt_intention(a,intent,thought):notify_event("INIZIATIVA AUTONOMA",a.name+" · "+intent.to_lower())
    refresh()
    return
   sim.remember(a,reply)
   sim.log_event(a.name+" [AI]: "+reply)
   hint.text="Risposta generativa ricevuta."
 refresh()

func save_game(show_hint:bool):
 save_path(SAVE_PREFIX+str(slot)+".json",show_hint)

func save_path(path:String,show_hint:bool)->bool:
 var d=sim.export_state()
 d["deformation"]=deformation
 d["planted"]=planted
 d["positions"]={}
 for id in actors:
  var p:Vector3=actors[id].node.position
  d.positions[str(id)]=[p.x,p.z]
 d["saved_at"]=Time.get_unix_time_from_system()
 d["camera"]=[focus.x,focus.z,azimuth,pitch,distance]
 var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null:
  if show_hint:hint.text="Impossibile salvare."
  return false
 file.store_string(JSON.stringify(d))
 file.close()
 var absolute=ProjectSettings.globalize_path(path)
 var backup=absolute+".bak"
 if FileAccess.file_exists(path):
  if FileAccess.file_exists(path+".bak"):DirAccess.remove_absolute(backup)
  if DirAccess.rename_absolute(absolute,backup)!=OK:return false
 var err=DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),absolute)
 if err!=OK:
  if FileAccess.file_exists(path+".bak"):DirAccess.rename_absolute(backup,absolute)
  if show_hint:hint.text="Impossibile completare il salvataggio."
  return false
 if show_hint:hint.text="Universo salvato nello slot "+str(slot+1)+"."
 return true

func load_game():
 load_path(SAVE_PREFIX+str(slot)+".json")

func load_path(p:String)->bool:
 if not FileAccess.file_exists(p) and not FileAccess.file_exists(p+".bak"):
  hint.text="Slot vuoto."
  return false
 var data=JSON.parse_string(FileAccess.get_file_as_string(p)) if FileAccess.file_exists(p) else null
 var candidate=Sim.new()
 if not data is Dictionary or not candidate.import_state(data):
  data=JSON.parse_string(FileAccess.get_file_as_string(p+".bak")) if FileAccess.file_exists(p+".bak") else null
  candidate=Sim.new()
  if not data is Dictionary or not candidate.import_state(data):
   hint.text="Salvataggio non valido."
   return false
 reset_ai_request()
 sim=candidate
 var advanced=0
 if absent_progress and not test_mode:
  advanced=sim.advance_absence(maxf(0,Time.get_unix_time_from_system()-float(data.get("saved_at",Time.get_unix_time_from_system()))))
 deformation=data.get("deformation",[])
 planted=data.get("planted",[])
 reset_visuals()
 var cam=data.get("camera",[])
 if cam.size()==5:
  focus=Vector3(float(cam[0]),0,float(cam[1]))
  azimuth=float(cam[2])
  pitch=clampf(float(cam[3]),.24,1.48)
  distance=clampf(float(cam[4]),3.0,125.0)
  update_camera()
 for id in actors:
  var pos=data.get("positions",{}).get(str(id),[])
  if pos.size()==2:actors[id].node.position=ground(float(pos[0]),float(pos[1]))
 selected=-1
 following=false
 show_ending=sim.ended==""
 speed=1
 tick=0
 refresh()
 hint.text="Universo ripristinato."
 if advanced>0:
  notify_event("Bentornato, Creatore","Durante la tua assenza: "+str(advanced)+" giorni.")
  save_path(p,false)
 return true

func self_test():
 var failed=false
 var asset_count=0
 for kind in ["tree","rock","house","industrial","future","animal","creature","prop","farm","early","cart"]:
  var n=art_catalog.get(kind,[]).size()
  asset_count+=n
  if n==0:failed=true
 if asset_count<60:failed=true
 for mode in [0,1,2,3]:
  var t=Sim.new()
  t.start(47+mode,mode)
  for i in range(270):
   if mode==3 and i%8==0:
    for v in t.villages:v.food+=32
   if mode==1:t.peace=maxf(85,t.peace)
   t.daily()
  print("SIM TEST mode=",mode," population=",t.people.size()," day=",t.day," tech=",t.discoveries.size()," ending=",t.ended)
  if t.people.is_empty() or t.discoveries.is_empty():failed=true
  if mode!=0 and t.ended=="":failed=true
  for j in range(t.signals.size()):
   if not t.find(int(t.signals[j].id)).is_empty():
    var old_decisions=t.decisions.size()
    if not t.answer_signal(j,1) or t.decisions.size()!=old_decisions+1 or t.answer_signal(j,1):failed=true
    break
  var state=JSON.parse_string(JSON.stringify(t.export_state()))
  var clone=Sim.new()
  if not clone.import_state(state) or clone.people.size()!=t.people.size() or clone.day!=t.day:failed=true
 if actors.size()!=sim.people.size():failed=true
 unlimited=true
 for p in POWERS.slice(1):
  power=p
  divine(centers[0])
 power="Osserva"
 var test_sim=Sim.new()
 test_sim.start(77,0)
 var candidate=test_sim.people[0]
 if not test_sim.adopt_intention(candidate,"RICERCA","Scelgo di studiare.") or test_sim.adopt_intention(candidate,"INVALIDO",""):failed=true
 var count_days=test_sim.advance_absence(1800)
 if count_days!=10 or test_sim.day!=10 or test_sim.autonomous_decisions!=1:failed=true
 var eternal=Sim.new()
 eternal.start(47,0)
 for i in range(3000):eternal.daily()
 if eternal.ended!="" or eternal.day!=3000 or eternal.projects_completed<5 or eternal.crises_seen<10:failed=true
 print("CRISIS_TEST events=",eternal.crises_seen," history=",eternal.crisis_history.size())
 var eternal_copy=Sim.new()
 if not eternal_copy.import_state(JSON.parse_string(JSON.stringify(eternal.export_state()))) or eternal_copy.projects_completed!=eternal.projects_completed or eternal_copy.crises_seen!=eternal.crises_seen:failed=true
 print("PROJECT_TEST completed=",eternal.projects_completed," births=",eternal.total_births," deaths=",eternal.total_deaths)
 for inhabitant in eternal.people.duplicate():eternal.die(inhabitant,"test")
 for i in range(10):eternal.daily()
 if eternal.ended!="" or eternal.day!=3010 or not eternal.people.is_empty():failed=true
 eternal.birth(0,[])
 eternal.birth(0,[])
 eternal.daily()
 if eternal.people.is_empty() or eternal.ended!="" or eternal.day!=3011:failed=true
 print("ETERNITY_TEST day=",eternal.day," population=",eternal.people.size()," ending=",eternal.ended)
 var test_path="user://genesis47_test.json"
 if not save_path(test_path,false):failed=true
 var before=sim.people.size()
 var before_day=sim.day
 var before_trees=planted.size()
 if not load_path(test_path) or sim.people.size()!=before or sim.day!=before_day or planted.size()!=before_trees:failed=true
 if not save_path(test_path,false):failed=true
 var corrupt=FileAccess.open(test_path,FileAccess.WRITE)
 if corrupt!=null:
  corrupt.store_string("invalid json")
  corrupt.close()
 if not load_path(test_path) or sim.people.size()!=before:failed=true
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(test_path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path+ext))
 print("SELF_TEST ", "FAIL" if failed else "PASS")
 get_tree().quit(1 if failed else 0)

func capture_preview():
 speed=0
 hud.hide()
 for i in range(55):
  sim.daily()
 apply_changes()
 for i in range(2):sync_houses(i)
 focus=(centers[0]+centers[1])*.5
 distance=55
 pitch=.76
 update_camera()
 await get_tree().create_timer(.5).timeout
 await RenderingServer.frame_post_draw
 var image=get_viewport().get_texture().get_image()
 var err=image.save_png("res://preview.png")
 hud.show()
 focus=centers[0]
 distance=22
 pitch=.58
 selected=sim.people[0].id if not sim.people.is_empty() else -1
 refresh()
 update_camera()
 await get_tree().create_timer(.4).timeout
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://preview-gameplay.png")
 hud.hide()
 if actors.has(selected):
  focus=actors[selected].node.position
  distance=3.0
  pitch=.30
  update_camera()
  await get_tree().create_timer(.4).timeout
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://preview-creature.png")
 speed=1
 await get_tree().create_timer(.7).timeout
 print("CAPTURE ",err)
 get_tree().quit(0 if err==OK else 1)

func populate_powers(i:int):
 if power_grid==null:return
 for child in power_grid.get_children():
  power_grid.remove_child(child)
  child.queue_free()
 power_buttons.clear()
 var group=GROUPS[clampi(i,0,GROUPS.size()-1)]
 var entries=group.duplicate()
 if not entries.has("Osserva"):entries.push_front("Osserva")
 for name_value in entries:
  var cost=18 if name_value in ["Meteorite","Tsunami","Vulcano","Resurrezione","Montagna","Lago"] else 9
  var display=name_value if name_value=="Osserva" else name_value+"  ·  "+str(cost)
  var b=button(power_grid,display,func():
   power=name_value
   power_label.text=name_value
   if hint!=null:hint.text=POWER_TIPS.get(name_value,"")
   for item in power_buttons:item.button_pressed=item.get_meta("power")==power)
  b.toggle_mode=true
  b.set_pressed_no_signal(power==name_value)
  b.set_meta("power",name_value)
  b.tooltip_text=POWER_TIPS.get(name_value,"")
  power_buttons.append(b)
func show_help():
 open_dialog("GUIDA AL CREATORE","BENVENUTO IN GENESIS 47\n\n1. Osserva la vita: clicca un abitante o premi Casuale, poi Segui.\n2. Usa la mappa per raggiungere una zona.\n3. Scegli una categoria di poteri. Il numero indica il costo in energia. Clicca il mondo per intervenire.\n4. Accelera il tempo e controlla le scoperte.\n5. Rispondi ai segnali degli abitanti: pace, guerra e conoscenza possono modificare il mondo.\n\nWASD = movimento | rotella = zoom | trascina il destro = rotazione\nSPAZIO = pausa | F1 = guida | F5 = salva | F9 = carica | F10 = cinema\n\nOllama è facoltativo. Il mondo non ha bisogno di Internet e continua autonomamente.\n\nOgni scenario ha un obiettivo nella barra inferiore. Puoi continuare anche dopo il finale.")
func show_achievements():
 var entries=["Un mondo vivo","La via del commercio","Il secolo delle scoperte","La mano del Creatore","Eredità"]
 var lines=["TRAGUARDI  %d / %d"%[sim.achievements.size(),entries.size()]]
 for e in entries:lines.append(("\u2713  " if sim.achievements.has(e) else "\u25cb  ")+e)
 lines.append("\n60 abitanti · 5 scambi · 14 scoperte · 10 poteri · 4 generazioni")
 open_dialog("TRAGUARDI","\n\n".join(lines))
func show_history():
 var lines=["NATI: %d   ·   DEFUNTI: %d   ·   OPERE: %d"%[sim.total_births,sim.total_deaths,sim.projects_completed],"Eventi storici: "+str(sim.crises_seen),"","GIORNO        POPOLAZIONE        PACE"]
 for row in sim.history.slice(maxi(0,sim.history.size()-30)):
  lines.append("%03d                   %03d                  %d%%"%[int(row.day),int(row.population),int(row.peace)])
 open_dialog("STORIA DEL MONDO","\n".join(lines))

func rebuild_roads():
 if not is_instance_valid(roads_root) or centers.size()!=2:return
 for child in roads_root.get_children():
  roads_root.remove_child(child)
  child.queue_free()
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var triangle_count=0
 for i in range(2):
  for j in range(houses[i].size()):
   var p=centers[i]
   var q=house_location(i,j)
   var dir=Vector2(q.x-p.x,q.z-p.z)
   if dir.length()<1:continue
   var perpendicular=dir.normalized().orthogonal()*.25
   var segments=maxi(3,ceili(dir.length()/0.55))
   for k in range(segments):
    var a=p.lerp(q,float(k)/segments)
    var b=p.lerp(q,float(k+1)/segments)
    var bend=Vector3(perpendicular.x,0,perpendicular.y)*1.1
    a+=bend*sin(float(k)/segments*PI)
    b+=bend*sin(float(k+1)/segments*PI)
    var left_a=ground(a.x+perpendicular.x,a.z+perpendicular.y)+Vector3.UP*.13
    var right_a=ground(a.x-perpendicular.x,a.z-perpendicular.y)+Vector3.UP*.13
    var left_b=ground(b.x+perpendicular.x,b.z+perpendicular.y)+Vector3.UP*.13
    var right_b=ground(b.x-perpendicular.x,b.z-perpendicular.y)+Vector3.UP*.13
    if minf(minf(left_a.y,right_a.y),minf(left_b.y,right_b.y))<SEA+.1:continue
    for v in [left_a,right_a,left_b,right_a,right_b,left_b]:
     st.add_vertex(v)
    triangle_count+=2
 if triangle_count==0:return
 st.generate_normals()
 var mi=MeshInstance3D.new()
 mi.mesh=st.commit()
 var mat=ShaderMaterial.new()
 mat.shader=path_shader
 mi.material_override=mat
 mi.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 roads_root.add_child(mi)

func update_time_buttons():
 for item in time_buttons:
  item.set_pressed_no_signal(float(item.get_meta("speed"))==speed)

func toggle_compact():
 compact=not compact
 if is_instance_valid(left_panel):left_panel.visible=not compact
 if is_instance_valid(right_panel):right_panel.visible=not compact
 if hint!=null:hint.text="TAB per ripristinare i pannelli" if compact else "WASD · rotella · tasto destro · F10 foto"

func show_options():
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title="OPZIONI"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 text_label(box,"Grafica · scegli in base al tuo PC",17)
 var quality=OptionButton.new()
 for item in ["Prestazioni","Bilanciata","Qualità"]:quality.add_item(item)
 quality.select(quality_mode)
 quality.item_selected.connect(func(i):
  apply_quality(i)
  store_settings())
 box.add_child(quality)
 var volume=HSlider.new()
 volume.min_value=0
 volume.max_value=100
 volume.value=volume_value
 volume.custom_minimum_size.x=300
 volume.value_changed.connect(func(v):volume_value=v;audio.volume_db=linear_to_db(maxf(.001,v/100.0))-17;store_settings())
 text_label(box,"Volume ambiente",14)
 box.add_child(volume)
 var auto=CheckButton.new()
 auto.text="Salvataggio automatico separato"
 auto.button_pressed=autosave_enabled
 auto.toggled.connect(func(v):autosave_enabled=v;store_settings())
 box.add_child(auto)
 var absence=CheckButton.new()
 absence.text="Evoluzione durante l’assenza (max 60 giorni)"
 absence.button_pressed=absent_progress
 absence.toggled.connect(func(v):absent_progress=v;store_settings())
 box.add_child(absence)
 button(box,"Schermo intero / finestra",func():DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN))
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(400,230))

func rebuild_farms():
 if not is_instance_valid(farms_root) or centers.size()!=2:return
 for child in farms_root.get_children():
  farms_root.remove_child(child)
  child.queue_free()
 farm_points=[[],[]]
 for i in range(2):
  if sim.villages[i].era<2:continue
  for j in range(2):
   var p=land_near(centers[i].x+(5.0 if i==0 else -5.0)+j*(2.5 if i==0 else -2.5),centers[i].z+5.8)
   farm_points[i].append(p)
   var n=asset(farms_root,"farm",j,p,.65,0)
   if n==null:
    n=Node3D.new()
    farms_root.add_child(n)
    n.position=p
    for row in range(3):
     for col in range(5):
      var q=Vector3((col-2)*.42,.04,(row-1)*.43)
      block(n,Color("795b41"),q,Vector3(.36,.08,.36))
      sphere(n,Color("b8bb59"),q+Vector3.UP*.22,Vector3(.18,.42,.18))

func spawn_caravan(clan:int):
 if not is_instance_valid(villages_root) or caravans.size()>3:return
 var origin=centers[clan]
 var n=asset(villages_root,"cart",clan,origin,.88)
 if n==null:return
 caravans.append({"node":n,"from":origin,"to":centers[1-clan],"progress":0.0})

func update_caravans(delta:float):
 if speed<=0:return
 for row in caravans.duplicate():
  if not is_instance_valid(row.node):
   caravans.erase(row)
   continue
  row.progress=minf(1,row.progress+delta*.035*minf(speed,8))
  var p:Vector3=row.from.lerp(row.to,row.progress)
  p.y=height_at(p.x,p.z)
  row.node.position=p
  var d:Vector3=row.to-row.from
  row.node.rotation.y=atan2(d.x,d.z)
  if row.progress>=1:
   row.node.queue_free()
   caravans.erase(row)

func create_clouds():
 if test_mode:return
 var mat=StandardMaterial3D.new()
 mat.albedo_color=Color(.86,.91,.92,.23)
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.cull_mode=BaseMaterial3D.CULL_DISABLED
 for i in range(9):
  var n=Node3D.new()
  ambient_root.add_child(n)
  n.position=Vector3(rng.randf_range(-75,75),rng.randf_range(18,28),rng.randf_range(-68,68))
  for j in range(4):
   var m=SphereMesh.new()
   m.radius=.5
   m.height=1.0
   m.radial_segments=12
   m.rings=6
   var puff=MeshInstance3D.new()
   puff.mesh=m
   puff.material_override=mat
   puff.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
   n.add_child(puff)
   puff.position=Vector3(j*3.2-4.8,sin(j*1.7)*.5,cos(j*1.1)*1.5)
   puff.scale=Vector3(7.0,2.1,4.7)
  clouds.append(n)

func update_clouds(delta:float):
 for n in clouds:
  if not is_instance_valid(n):continue
  n.visible=quality_mode>0 and distance>22
  if n.visible:
   n.position.x+=delta*.22
   if n.position.x>80:n.position.x=-80

func impact_cloud(p:Vector3):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p+Vector3.UP*.3
 var l=OmniLight3D.new()
 n.add_child(l)
 l.light_color=Color("ffb469")
 l.light_energy=6
 l.omni_range=16
 var ring=TorusMesh.new()
 ring.inner_radius=.9
 ring.outer_radius=1.05
 var shock=piece(n,ring,Color("ffc079"),Vector3.UP*.1,Vector3.ONE,1.4)
 shock.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var particles=CPUParticles3D.new()
 n.add_child(particles)
 particles.amount=72
 particles.lifetime=1.6
 particles.one_shot=true
 particles.explosiveness=.92
 particles.direction=Vector3.UP
 particles.spread=83
 particles.initial_velocity_min=3
 particles.initial_velocity_max=9
 particles.gravity=Vector3(0,-5,0)
 particles.scale_amount_min=.25
 particles.scale_amount_max=1.0
 var m=SphereMesh.new()
 m.radius=.17
 m.height=.34
 m.radial_segments=7
 m.rings=4
 m.material=material(Color("d38d57"),.9,.25)
 particles.mesh=m
 particles.restart()
 particles.emitting=true
 effects.append({"node":n,"life":2.0,"max":2.0,"kind":"impact"})

func play_event_sound(danger:bool):
 var key="danger" if danger else "gentle"
 if not event_sounds.has(key):
  var rate=16000
  var frames=rate*2
  var bytes=PackedByteArray()
  bytes.resize(frames*2)
  var srng=RandomNumberGenerator.new()
  srng.seed=73 if danger else 47
  for i in range(frames):
   var t=float(i)/rate
   var envelope=exp(-t*(2.6 if danger else 3.8))*minf(1,t*45)
   var v=0.0
   if danger:v=(sin(TAU*(55*t+18*t*t))*.52+srng.randf_range(-1,1)*.25)*envelope
   else:v=(sin(TAU*392*t)*.36+sin(TAU*587*t)*.23+sin(TAU*784*t)*.12)*envelope
   bytes.encode_s16(i*2,int(clampf(v,-1,1)*22000))
  var clip=AudioStreamWAV.new()
  clip.format=AudioStreamWAV.FORMAT_16_BITS
  clip.mix_rate=rate
  clip.data=bytes
  event_sounds[key]=clip
 event_player.stream=event_sounds[key]
 event_player.stream_paused=audio.stream_paused
 event_player.play()

func apply_quality(i:int):
 quality_mode=clampi(i,0,2)
 sun.shadow_enabled=quality_mode>0
 get_viewport().msaa_3d=Viewport.MSAA_4X if quality_mode==2 else Viewport.MSAA_2X if quality_mode==1 else Viewport.MSAA_DISABLED
 get_viewport().scaling_3d_scale=.85 if quality_mode==0 else 1.0

func restore_settings():
 if settings.load("user://genesis47_settings.cfg")!=OK:return
 apply_quality(int(settings.get_value("game","quality",1)))
 autosave_enabled=bool(settings.get_value("game","autosave",true))
 absent_progress=bool(settings.get_value("game","absence",false))
 ai_autonomy=bool(settings.get_value("game","ai_autonomy",true))
 volume_value=float(settings.get_value("game","volume",50))
 audio.volume_db=linear_to_db(maxf(.001,volume_value/100.0))-17
 audio.stream_paused=bool(settings.get_value("game","muted",false))

func store_settings():
 settings.set_value("game","quality",quality_mode)
 settings.set_value("game","autosave",autosave_enabled)
 settings.set_value("game","absence",absent_progress)
 settings.set_value("game","ai_autonomy",ai_autonomy)
 settings.set_value("game","volume",volume_value)
 settings.set_value("game","muted",audio.stream_paused)
 settings.save("user://genesis47_settings.cfg")

func self_test_ai():
 if sim.people.is_empty():
  get_tree().quit(1)
  return
 selected=int(sim.people[0].id)
 input.text="Ciao, come ti senti oggi?"
 ask_ai()
 for i in range(180):
  if ai_reply_received:break
  await get_tree().create_timer(.5).timeout
 print("AI_TEST ", "PASS" if ai_reply_received else "FAIL")
 get_tree().quit(0 if ai_reply_received else 1)

func notify_event(heading:String,message:String):
 if test_mode or not is_instance_valid(toast_panel):return
 toast_label.text=heading+"\n"+message
 toast_panel.show()
 toast_time=4.0

func reset_ai_request():
 if is_instance_valid(request):request.cancel_request()
 request_target=-1
 ai_busy=false
 ai_is_autonomous=false
 last_ai_day=-1
 ai_cooldown=0.0
 if is_instance_valid(ai_button):ai_button.disabled=false

func ask_autonomous():
 if sim.people.is_empty() or not is_instance_valid(request) or ai_busy:return
 var adults=sim.people.filter(func(a):return a.age>=14 and int(a.get("intention_until",0))<=sim.day)
 if adults.is_empty():return
 var a=adults[rng.randi_range(0,adults.size()-1)]
 var v=sim.villages[a.clan]
 var prompt="Sei %s, creatura immaginaria autonoma del gioco. Salute %d, fame %d, umore %d, pace tra popoli %d, scorte %d, mestiere %s. Scegli una sola priorità tra RICERCA, CIBO, CURA, PACE, ESPLORA. Scrivi esattamente CODICE|una frase in italiano che spiega la tua scelta. Nessun altro testo."%[a.name,int(a.health),int(a.hunger),int(a.mood),int(sim.peace),int(v.food),a.role]
 var payload={"model":"genesis-local","messages":[{"role":"user","content":prompt}],"stream":false,"max_tokens":65,"temperature":.35}
 last_ai_day=sim.day
 ai_cooldown=22.0
 var err=request.request("http://127.0.0.1:17847/v1/chat/completions",["Content-Type: application/json"],HTTPClient.METHOD_POST,JSON.stringify(payload))
 if err==OK:
  request_target=a.id
  ai_busy=true
  ai_is_autonomous=true
  if ai_button!=null:ai_button.disabled=true

func family_names(ids:Array)->String:
 var names=[]
 for id in ids:
  if int(id)<0:continue
  var a=sim.find(int(id))
  if not a.is_empty():names.append(a.name)
  else:
   var found=false
   for old in sim.dead:
    if int(old.id)==int(id):
     names.append(str(old.name)+" †")
     found=true
     break
   if not found:names.append("#"+str(id))
 return "—" if names.is_empty() else ", ".join(names)

func show_projects():
 var lines=["Le civiltà avviano opere autonomamente. Ogni opera richiede legna, tempo e cibo; gli effetti continuano dopo il completamento.",""]
 for i in range(2):
  var v=sim.villages[i]
  lines.append(Sim.CLANS[i]+" · "+str(v.completed)+" opere completate")
  lines.append("In corso: "+(Sim.PROJECT_NAMES[int(v.project)]+" — "+str(int(v.progress))+"%" if int(v.project)>=0 else "Nessuna"))
  for j in range(6):
   lines.append("  "+Sim.PROJECT_NAMES[j]+": "+str(v.bonuses[j]))
  lines.append("")
 open_dialog("OPERE DELLE CIVILTÀ","\n".join(lines))

func rebuild_civic():
 if not is_instance_valid(civic_root) or centers.size()!=2:return
 for n in civic_root.get_children():
  civic_root.remove_child(n)
  n.queue_free()
 civic_spinners.clear()
 for i in range(2):
  var v=sim.villages[i]
  if int(v.completed)<=0:continue
  var pos=land_near(centers[i].x+(2.9 if i==0 else -2.9),centers[i].z-3.0)
  var plaza=Node3D.new()
  civic_root.add_child(plaza)
  plaza.position=pos
  var trim=Color("73bab2") if i==0 else Color("dcac69")
  cone(plaza,Color("9b9d93"),Vector3(0,.10,0),1.35,.2,1.35,12)
  cone(plaza,Color("d3d0b8"),Vector3(0,.28,0),1.0,.18,1.0,12)
  var h=1.6+minf(1.4,float(v.completed)*.10)
  for j in range(4):
   var angle=TAU*j/4
   var foot=Vector3(cos(angle)*.65,0,sin(angle)*.65)
   cone(plaza,Color("c3c9be"),foot+Vector3.UP*(h*.5+.4),.13,h,.10,8)
   block(plaza,trim,foot+Vector3.UP*(h+.44),Vector3(.36,.12,.36))
  var rotor=Node3D.new()
  plaza.add_child(rotor)
  rotor.position.y=h+.55
  var r=TorusMesh.new()
  r.inner_radius=.48
  r.outer_radius=.57
  var a=piece(rotor,r,trim,Vector3.ZERO,Vector3.ONE,.4)
  a.rotation.x=PI/2
  var b=piece(rotor,r,Color("f5dcb0"),Vector3.ZERO,Vector3.ONE*.82,.6)
  b.rotation.z=.8
  sphere(rotor,trim,Vector3.ZERO,Vector3.ONE*.42,.65)
  civic_spinners.append(rotor)
  if int(v.completed)>=4:
   for j in range(6):
    var angle=j*TAU/6
    var offset=Vector3(cos(angle)*1.05,.36,sin(angle)*1.05)
    sphere(plaza,trim,offset,Vector3.ONE*.15,.4)

func choose_motion(ap:AnimationPlayer,moving:bool):
 var terms=["walk","run"] if moving else ["idle","rest"]
 for term in terms:
  for clip_name in ap.get_animation_list():
   if str(clip_name).to_lower().contains(term):
    if ap.current_animation!=clip_name:ap.play(clip_name,.18)
    ap.speed_scale=1.0
    return
 ap.speed_scale=1.0 if moving else 0.0

func _notification(what:int):
 if what==NOTIFICATION_WM_CLOSE_REQUEST and not test_mode:
  if world_started and autosave_enabled and sim.villages.size()==2:
   save_path("user://genesis47_auto.json",false)
  get_tree().quit()
