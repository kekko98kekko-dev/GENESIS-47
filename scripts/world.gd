extends Node3D
const Sim=preload("res://scripts/sim.gd")
const SEA=-0.40
const GRID=116
const STEP=0.912
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
var inspector_tabs:TabContainer
var season_material:ShaderMaterial
var last_season=""
var event_feed:RichTextLabel
var mood_bar:ProgressBar
var hunger_bar:ProgressBar
var trade_route:PackedVector3Array=PackedVector3Array()
var route_root:Node3D
var terrain_revision=0
var selected_marker:Label3D
var route_status:Label
var dialogue_view:RichTextLabel
var dialogue_heading:Label
var trust_bar:ProgressBar
var settlement_root:Node3D
var meadow:MultiMeshInstance3D
var tour=false
var tour_clock=0.0
var tour_index=-1
var tour_button:Button
var fps_label:Label
var fps_clock=0.0
var unlimited_toggle:CheckButton
var onboarding:PanelContainer
var onboarding_label:Label
var onboarding_step=0
var onboarding_enabled=true
var landmark_root:Node3D
var village_lights:Array=[]
var social_summary:Label
var shared_sphere:SphereMesh
var shared_box:BoxMesh
var skin_cache:Dictionary={}
var benchmark_mode=false
var nav_grid=AStarGrid2D.new()
var nav_dirty=true
var nav_version=0
var autonomy_clock=0.0
var timber_points:Array=[]
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
 benchmark_mode="--benchmark" in OS.get_cmdline_user_args() or "--benchmark-test" in OS.get_cmdline_user_args()
 portable_ai="--portable-ai" in OS.get_cmdline_user_args() and not benchmark_mode
 ai_test="--ai-test" in OS.get_cmdline_user_args()
 test_mode="--self-test" in OS.get_cmdline_user_args() or ai_test
 load_catalog()
 setup_environment()
 setup_ui()
 if not test_mode and not benchmark_mode and not "--capture" in OS.get_cmdline_user_args():restore_settings()
 request=HTTPRequest.new()
 add_child(request)
 request.timeout=90
 request.request_completed.connect(ai_response)
 new_world(47,0)
 if ai_test:
  call_deferred("self_test_ai")
 elif test_mode:
  call_deferred("self_test")
 elif benchmark_mode:
  autosave_enabled=false
  call_deferred("run_benchmark")
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
 if shared_sphere==null:
  shared_sphere=SphereMesh.new()
  shared_sphere.radius=.5
  shared_sphere.height=1.0
  shared_sphere.radial_segments=24
  shared_sphere.rings=12
 return piece(parent,shared_sphere,c,p,s,glow)

func block(parent:Node3D,c:Color,p:Vector3,s:Vector3,glow=0.0)->MeshInstance3D:
 if shared_box==null:
  shared_box=BoxMesh.new()
  shared_box.size=Vector3.ONE
 return piece(parent,shared_box,c,p,s,glow)

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
 sky_material.sun_angle_max=14
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
 sun.shadow_bias=.045
 sun.shadow_normal_bias=.9
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
 terrain_revision+=1
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
 season_material=m
 last_season=""
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
 set_tour(false)
 unlimited=false
 if is_instance_valid(unlimited_toggle):unlimited_toggle.set_pressed_no_signal(false)
 planted.clear()
 sim.start(seed_value,which)
 sim.spatial_autonomy=not test_mode and not benchmark_mode and not "--capture" in OS.get_cmdline_user_args()
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
 nav_dirty=true
 timber_points.clear()
 for n in [earth,sea,scenery,villages_root,people_root,animals_root,effects_root,cursor,roads_root,farms_root,hover_ring,ambient_root,civic_root,route_root,selected_marker,settlement_root,meadow,landmark_root]:
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
 village_lights.clear()
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
 route_root=Node3D.new()
 settlement_root=Node3D.new()
 landmark_root=Node3D.new()
 for n in [scenery,villages_root,people_root,animals_root,effects_root,roads_root,farms_root,ambient_root,civic_root,route_root,settlement_root,landmark_root]:add_child(n)
 rebuild_trade_route()
 create_clouds()
 for i in range(2):
  make_hub(i)
  sync_houses(i)
 rebuild_roads()
 rebuild_farms()
 rebuild_civic()
 rebuild_settlement_details()
 rebuild_landmarks()
 rebuild_meadow()
 for i in range(350):
  var p=ground(rng.randf_range(-45,45),rng.randf_range(-42,42))
  if p.y>SEA+.85 and p.y<8.5 and far_village(p,9) and away_from_route(p,1.65):
   make_tree(p,rng.randf_range(2.3,4.8),i)
 for row in planted:
  var place=ground(float(row.x),float(row.z))
  if place.y>SEA+.12:make_tree(place,float(row.h),int(row.i))
 for i in range(100):
  var p=ground(rng.randf_range(-46,46),rng.randf_range(-43,43))
  if p.y>SEA+.2 and far_village(p,4) and away_from_route(p,1.05):
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
 for shipment in sim.shipments:spawn_caravan(int(shipment.id))
 sim.changes.clear()
 cursor=MeshInstance3D.new()
 var ring=TorusMesh.new()
 ring.inner_radius=.43
 ring.outer_radius=.49
 cursor.mesh=ring
 cursor.material_override=material(Color("fff0b3"),.5,1.1)
 add_child(cursor)
 cursor.hide()
 selected_marker=Label3D.new()
 add_child(selected_marker)
 selected_marker.font_size=34
 selected_marker.pixel_size=.007
 selected_marker.outline_size=6
 selected_marker.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 selected_marker.modulate=Color("fff0b3")
 selected_marker.hide()
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
 timber_points.append(p)
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
 var r=4.5+sqrt(float(j))*3.15
 return land_near(centers[i].x+cos(a)*r,centers[i].z+sin(a)*r)

func make_house(i:int,j:int,era:int):
 var p=house_location(i,j)
 var n=Node3D.new()
 villages_root.add_child(n)
 n.position=p
 n.rotation.y=atan2(centers[i].x-p.x,centers[i].z-p.z)
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
 if j%4==0 and era>=2:
  var lamp=Node3D.new()
  n.add_child(lamp)
  lamp.position=Vector3(1.1,0,1.6)
  cone(lamp,Color("695d48"),Vector3.UP*.48,.045,.96,.035,6)
  block(lamp,Color("584b3a"),Vector3.UP*1.02,Vector3(.23,.10,.23))
  sphere(lamp,Color("ffcc83"),Vector3.UP*.94,Vector3(.17,.20,.17),.55)
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
 var skin=Color("399c98").lerp(Color("93d6b6"),float(a.genes[2])) if a.clan==0 else Color("a95c3f").lerp(Color("e8be78"),float(a.genes[2]))
 var cloth=Color("244b59") if a.clan==0 else Color("683e4c")
 var accent=Color("c5f2d7") if a.clan==0 else Color("ffe3a1")
 var body=Node3D.new()
 parent.add_child(body)
 var torso=sphere(body,skin,Vector3(0,.70,0),Vector3(.67,.80,.53))
 torso.material_override=creature_skin(skin)
 sphere(body,cloth,Vector3(0,.62,-.19),Vector3(.62,.57,.25))
 var head=sphere(body,skin.lightened(.07),Vector3(0,1.24,.025),Vector3(.77,.70,.65))
 head.material_override=creature_skin(skin.lightened(.07))
 sphere(body,skin.lightened(.25),Vector3(0,.77,.245),Vector3(.41,.45,.12))
 sphere(body,cloth,Vector3(0,.50,0),Vector3(.66,.15,.54))
 sphere(body,accent,Vector3(0,.51,.27),Vector3(.14,.13,.06),.15)
 var arms=[]
 var legs=[]
 var eyes=[]
 for side in [-1,1]:
  var ear=sphere(body,skin.darkened(.08),Vector3(side*.39,1.42,.0),Vector3(.24,.38,.18))
  ear.rotation.z=side*-.56
  ear.scale.y*=lerpf(.75,1.30,float(a.genes[0]))
  sphere(body,skin.lightened(.25),Vector3(side*.39,1.43,.083),Vector3(.11,.22,.05)).rotation.z=side*-.56
  var eye=Node3D.new()
  body.add_child(eye)
  eye.position=Vector3(side*.18,1.30,.29)
  sphere(eye,Color("f2e6c9"),Vector3.ZERO,Vector3(.25,.28,.15))
  sphere(eye,Color("8b673d"),Vector3(0,0,.07),Vector3(.16,.19,.07))
  sphere(eye,Color("263b3a"),Vector3(0,0,.107),Vector3(.107,.139,.045))
  sphere(eye,Color("fff9e2"),Vector3(-.035,.05,.13),Vector3(.047,.047,.024))
  eyes.append(eye)
  var brow=sphere(body,skin.darkened(.26),Vector3(side*.18,1.49,.28),Vector3(.19,.048,.045))
  brow.rotation.z=side*lerpf(-.10,.18,float(a.genes[0]))
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
  sphere(body,accent,Vector3((j-1)*.10,1.55,.20),Vector3(.06,.08,.035),.5)
 var crest=cone(body,skin.lightened(.18),Vector3(0,1.68,-.08),.11,.18+float(a.genes[3])*.22,.015,7)
 crest.rotation.x=-.35
 if a.genes[1]>.55:
  for side in [-1,1]:sphere(body,accent,Vector3(side*.27,1.16,.28),Vector3(.09,.045,.027))
 return {"body":body,"arms":arms,"legs":legs,"eyes":eyes}

func create_actor(a:Dictionary):
 if actors.has(a.id):return
 var parent=Node3D.new()
 people_root.add_child(parent)
 parent.position=random_near(centers[a.clan],6.5)
 var visual:Node3D=null
 # Original coherent species; legacy stock models remain licensed in the catalog.
 var rig={}
 if visual==null:
  rig=original_creature(parent,a)
  rig.body.scale=Vector3.ONE*.68
 else:
  start_animation(visual,["walk","run","idle"])
  rig={"body":visual,"arms":[],"legs":[]}
 actors[a.id]={"node":parent,"body":rig.body,"arms":rig.arms,"legs":rig.legs,"target":random_near(centers[a.clan],7),"phase":rng.randf()*TAU}
 actors[a.id]["animation"]=animation_player(visual) if visual!=null else null
 actors[a.id]["moving"]=true
 actors[a.id]["eyes"]=rig.get("eyes",[])
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
 var signet=Label3D.new()
 parent.add_child(signet)
 signet.position=Vector3(0,.94,0)
 signet.text="◆"
 signet.font_size=25
 signet.outline_size=5
 signet.pixel_size=.005
 signet.modulate=Color("b9f4dd") if a.clan==0 else Color("ffdb9b")
 signet.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 signet.hide()
 actors[a.id]["signet"]=signet

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
    nav_dirty=true
    rebuild_farms()
    rebuild_settlement_details()
    rebuild_landmarks()
   "trade":spawn_caravan(int(e.id))
   "trade_arrived":remove_caravan(int(e.id))
   "project":rebuild_civic()
   "migration":
    var a=sim.find(int(e.id))
    if not a.is_empty() and actors.has(a.id):
     a.task=""
     actors[a.id]["route"]=[]
     actors[a.id]["planned_task"]=""
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
 camera.position.y=maxf(camera.position.y,height_at(camera.position.x,camera.position.z)+.85)
 camera.look_at(focus,Vector3.UP)

func _process(delta:float):
 if camera==null or centers.size()!=2 or test_mode:return
 visual_time+=delta
 fps_clock+=delta
 if fps_clock>=1.0:
  fps_clock=0.0
  if is_instance_valid(fps_label):fps_label.text=str(Engine.get_frames_per_second())+" FPS"
 if tour:update_tour(delta)
 ai_cooldown=maxf(0,ai_cooldown-delta)
 if speed>0 and portable_ai and ai_autonomy and not ai_busy and sim.day>=12 and sim.day-last_ai_day>=12 and ai_cooldown<=0:
  ask_autonomous()
 if toast_time>0:
  toast_time-=delta
  if toast_time<=0 and is_instance_valid(toast_panel):toast_panel.hide()
 var focused=get_viewport().gui_get_focus_owner()
 var keyboard_ok=not (focused is LineEdit or focused is TextEdit) and not welcome_open
 var mov=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if keyboard_ok and mov.length()>0:
  set_tour(false)
  following=false
  var right=Vector3(cos(azimuth),0,-sin(azimuth))
  var back=Vector3(sin(azimuth),0,cos(azimuth))
  focus+=(right*mov.x+back*mov.y)*delta*distance*.40
  focus.x=clampf(focus.x,-50,50)
  focus.z=clampf(focus.z,-50,50)
  update_camera()
 if is_instance_valid(meadow):
  meadow.visible=quality_mode>0 and distance<82
  meadow.multimesh.visible_instance_count=meadow.multimesh.instance_count if quality_mode==2 else mini(2600,meadow.multimesh.instance_count)
 if last_season!=sim.season:
  last_season=sim.season
  if is_instance_valid(season_material):season_material.set_shader_parameter("season_tint",{"Primavera":Color("e5ffd5"),"Estate":Color("fff2ca"),"Autunno":Color("f6ce96"),"Inverno":Color("c6dce3")}.get(last_season,Color.WHITE))
 for a in sim.people:
  if actors.has(a.id):
   var anim=actors[a.id].get("animation")
   if is_instance_valid(anim):anim.active=speed>0
 if speed>0:
  tick+=minf(delta,.1)*(minf(speed,20.0)/5.0 if sim.spatial_autonomy else speed)
  var loops=0
  while tick>=1.7 and loops<8 and speed>0:
   tick-=1.7
   step_day()
   loops+=1
  if nav_dirty:rebuild_navigation()
  for a in sim.people:
   if not actors.has(a.id):continue
   var r=actors[a.id]
   var n:Node3D=r.node
   var step=delta*minf(speed,20.0)*lerpf(.75,1.25,float(a.genes[3]))
   var moving=advance_actor_task(a,r,delta*minf(speed,20.0))
   if r.get("moving",true)!=moving:
    r.moving=moving
    if is_instance_valid(r.get("animation")):choose_motion(r.animation,moving)
   if activity_labels.has(a.id):
    var tag:Label3D=activity_labels[a.id]
    tag.visible=(show_labels or a.id==selected) and distance<36
    tag.text=a.name+" · "+str(a.get("task_stage",""))+" · "+str(a.get("activity","Decide"))
   r.phase+=step*7 if moving else delta*1.8
   if not r.legs.is_empty():
    r.body.position.y=absf(sin(r.phase))*(.05 if moving else .015)
    r.body.rotation.z=sin(r.phase*.5)*(.05 if moving else .025)
    r.body.rotation.x=lerpf(r.body.rotation.x,-.10 if moving else .10 if a.activity=="Riposa" else 0.0,minf(delta*5,1))
    for i in range(2):
     r.legs[i].rotation.x=sin(r.phase+i*PI)*(.46 if moving else .025)
     r.arms[i].rotation.x=sin(r.phase+i*PI+PI)*(.32 if moving else .045)
     if not moving and a.activity in ["Studia","Lavora al progetto","Aiuta un vicino","Coltiva","Raccoglie legna","Mangia","Si cura"]:r.arms[i].rotation.x=-.55+sin(r.phase*2.0+i)*.22
   if distance<24:
    var blink_phase=fposmod(visual_time+float(a.id)*1.37,4.2+float(a.genes[0]))
    var blink=1.0-.93*maxf(0.0,1.0-absf(blink_phase-.12)/.12)
    for eye in r.get("eyes",[]):eye.scale.y=blink
   n.scale=Vector3.ONE*clampf(.50+a.age/26,.5,1)*lerpf(.89,1.11,float(a.genes[3]))
   if is_instance_valid(r.get("signet")):
    r.signet.visible=distance<20 and not photo_mode and (a.favorite or a.id==selected or a.sick>0)
    r.signet.text="★" if a.favorite else "+" if a.sick>0 else "◆"
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
  autonomy_clock+=delta
  if autonomy_clock>=.5:
   autonomy_clock=0.0
   if actors.has(selected):refresh()
  var phase=fmod(float(sim.day)+tick/1.7,16.0)/16.0
  var daylight=clampf(.66+.43*sin(phase*TAU+.8),.20,1)
  sun.light_energy=.14+daylight*.83
  sun.light_color=Color("a4baff").lerp(Color("ffe7bd"),daylight)
  sun.rotation_degrees=Vector3(-22-daylight*38,-37+sin(phase*TAU)*24,0)
  env.ambient_light_color=Color("a4bdd8").lerp(Color("e2e7d3"),daylight)
  env.ambient_light_energy=.12+daylight*.31
  for lamp in village_lights:
   if is_instance_valid(lamp):lamp.light_energy=(1.0-daylight)*.85 if quality_mode>0 else 0.0
  sky_material.sky_top_color=Color("172b51").lerp(Color("4d86b4"),daylight)
  sky_material.sky_horizon_color=Color("495478").lerp(Color("cfdfd4"),daylight)
  env.fog_light_color=Color("374f68").lerp(Color("afc8cf"),daylight)
 if actors.has(selected):
  var n:Node3D=actors[selected].node
  cursor.show()
  cursor.position=n.position+Vector3(0,.045,0)
  selected_marker.position=n.position+Vector3.UP*1.42
  selected_marker.text="◆"
  selected_marker.visible=distance>=20 and distance<35 and not photo_mode
  if following:
   focus=focus.lerp(n.position,clampf(delta*6,0,1))
   update_camera()
 else:
  cursor.hide()
  selected_marker.hide()
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
  if event.keycode==KEY_F2:start_onboarding()
  if event.keycode==KEY_TAB:toggle_compact()
  if event.keycode==KEY_F6:set_tour(not tour)
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
 if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
  set_tour(false)
  following=false
  var right=Vector3(cos(azimuth),0,-sin(azimuth))
  var back=Vector3(sin(azimuth),0,cos(azimuth))
  focus-=right*event.relative.x*distance*.0018
  focus-=back*event.relative.y*distance*.0018
  focus.x=clampf(focus.x,-50,50)
  focus.z=clampf(focus.z,-50,50)
  update_camera()
 if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
  set_tour(false)
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
   set_tour(false)
   if power=="Osserva":
    select_at(event.position)
    if selected>=0 and onboarding_step==1 and onboarding.visible:advance_onboarding()
    if event.double_click and actors.has(selected):follow_person(selected)
   else:
    var p=ground_at(event.position)
    if p.y>SEA-.5 and absf(p.x)<51 and absf(p.z)<51:divine(p)

func ground_at(mouse:Vector2)->Vector3:
 var origin=camera.project_ray_origin(mouse)
 var dir=camera.project_ray_normal(mouse)
 var previous=origin
 for i in range(600):
  var p=origin+dir*i*.35
  if p.y<=height_at(p.x,p.z):
   var lo=previous
   var hi=p
   for j in range(7):
    var mid=(lo+hi)*.5
    if mid.y>height_at(mid.x,mid.z):lo=mid
    else:hi=mid
   return ground(hi.x,hi.z)
  previous=p
 return Vector3(0,-100,0)

func select_at(mouse:Vector2):
 var best=28.0
 var nearest_depth=INF
 selected=-1
 following=false
 for id in actors:
  var p:Vector3=actors[id].node.position+Vector3(0,.55,0)
  if camera.is_position_behind(p):continue
  var dist=camera.unproject_position(p).distance_to(mouse)
  var depth=camera.position.distance_to(p)
  if dist<best-.5 or (absf(dist-best)<=.5 and depth<nearest_depth):
   best=dist
   nearest_depth=depth
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
 nav_dirty=true
 if deformation.size()>=48:deformation.pop_front()
 deformation.append({"x":p.x,"z":p.z,"h":amount,"r":r})
 make_terrain()
 for collection in [scenery,villages_root,people_root,animals_root,civic_root,farms_root]:
  for n in collection.get_children():
   if n is Node3D:n.position.y=height_at(n.position.x,n.position.z)
 for i in range(centers.size()):centers[i]=ground(centers[i].x,centers[i].z)
 rebuild_roads()
 rebuild_trade_route()
 rebuild_settlement_details()
 rebuild_landmarks()
 rebuild_meadow()

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
    a.genes[3]=clampf(a.genes[3]+rng.randf_range(-.15,.15),0,1)
    if actors.has(a.id):
     var old_position:Vector3=actors[a.id].node.position
     actors[a.id].node.queue_free()
     actors.erase(a.id)
     activity_labels.erase(a.id)
     create_actor(a)
     actors[a.id].node.position=old_position
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
 for a in near:
  if sim.find(int(a.id)).is_empty():continue
  if power in ["Guarigione","Provviste","Pace","Pioggia"]:sim.adjust_trust(a,5)
  elif power in ["Meteorite","Fulmine","Tsunami","Vulcano","Carestia"]:sim.adjust_trust(a,-12)
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
 fps_label=text_label(row,"",12)
 fps_label.modulate=Color("a7d9bc")
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
 button(lv,"Osserva il mondo",func():power="Osserva";selected=-1;following=false;refresh();populate_powers(power_category.selected))
 text_label(lv,"MAPPA DEL MONDO",13)
 map_view=preload("res://scripts/minimap.gd").new()
 map_view.world=self
 map_view.custom_minimum_size=Vector2(155,135)
 lv.add_child(map_view)
 unlimited_toggle=CheckButton.new()
 unlimited_toggle.text="Energia infinita"
 unlimited_toggle.toggled.connect(func(on):unlimited=on)
 lv.add_child(unlimited_toggle)
 var right=panel(hud,Rect2(1107,104,319,650),.88)
 right_panel=right
 var rv=VBoxContainer.new()
 right.add_child(rv)
 text_label(rv,"VITA  /  CIVILTÀ",18)
 inspector_tabs=TabContainer.new()
 inspector_tabs.size_flags_vertical=Control.SIZE_EXPAND_FILL
 rv.add_child(inspector_tabs)
 var inspect=VBoxContainer.new()
 inspect.name="Osserva"
 inspector_tabs.add_child(inspect)
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
 inspect.add_child(status_bar)
 stats_bar=text_label(inspect,"",13)
 stats_bar.modulate=Color("a7d9bc")
 selected_status=text_label(inspect,"Osservazione del mondo",13)
 selected_status.modulate=Color("a7d9bc")
 mood_bar=small_meter(inspect,"Umore",Color("79bda2"))
 hunger_bar=small_meter(inspect,"Sazietà",Color("e1bc78"))
 trust_bar=small_meter(inspect,"Fiducia",Color("9eb9ed"))
 details=rich(inspect,235)
 details.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var line=HBoxContainer.new()
 inspect.add_child(line)
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
 var personal=HBoxContainer.new()
 inspect.add_child(personal)
 button(personal,"Biografia",show_biography)
 button(personal,"Famiglia",show_family)
 button(personal,"Rinomina",rename_selected)
 var archive=VBoxContainer.new()
 archive.name="Mondo"
 inspector_tabs.add_child(archive)
 text_label(archive,"ARCHIVI E CIVILTÀ",15)
 var line2=HBoxContainer.new()
 archive.add_child(line2)
 button(line2,"Atlante",show_atlas)
 signals_button=button(line2,"Segnali",show_signals)
 button(line2,"Scoperte",show_tech)
 button(archive,"Progetti delle civiltà",show_projects)
 var extra=HBoxContainer.new()
 archive.add_child(extra)
 button(extra,"Traguardi",show_achievements)
 button(extra,"Statistiche",show_history)
 button(extra,"Nomi",func():show_labels=not show_labels)
 button(archive,"Cronaca completa",func():open_dialog("CRONACA","\n".join(sim.events)))
 button(archive,"Storia delle crisi",show_crisis_history)
 social_summary=text_label(archive,"",13)
 social_summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 route_status=text_label(archive,"",13)
 button(archive,"Osserva la via commerciale",func():following=false;focus=(centers[0]+centers[1])*.5;distance=37;pitch=.8;update_camera())
 event_feed=rich(archive,170)
 event_feed.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var chat=VBoxContainer.new()
 chat.name="Dialogo"
 inspector_tabs.add_child(chat)
 dialogue_heading=text_label(chat,"PARLA CON LA VITA",15)
 dialogue_view=rich(chat,225)
 dialogue_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
 dialogue_view.scroll_following=true
 input=LineEdit.new()
 input.placeholder_text="Scrivi al tuo universo..."
 input.max_length=400
 chat.add_child(input)
 button(chat,"Invia messaggio",send_message)
 input.text_submitted.connect(func(_message):send_message())
 model=LineEdit.new()
 model.text="qwen2.5:1.5b"
 model.placeholder_text="Modello Ollama locale"
 chat.add_child(model)
 model.visible=not portable_ai
 ai_button=button(chat,"Risposta generativa" if portable_ai else "Risposta generativa (Ollama)",ask_ai)
 if portable_ai:
  var autonomy=CheckButton.new()
  autonomy.text="Iniziativa autonoma AI"
  autonomy.button_pressed=ai_autonomy
  autonomy.toggled.connect(func(on):ai_autonomy=on;store_settings())
  chat.add_child(autonomy)
 button(chat,"Segnali delle creature",show_signals)
 text_label(chat,"Seleziona un abitante prima di parlargli.",12).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var bottom=panel(hud,Rect2(14,769,1412,117),.91)
 bottom_panel=bottom
 var bv=VBoxContainer.new()
 bottom.add_child(bv)
 var controls=HBoxContainer.new()
 bv.add_child(controls)
 text_label(controls,"TEMPO",15)
 for s in [0.0,1.0,3.0,12.0,20.0]:
  var tb=button(controls,"Pausa" if s==0 else str(int(s))+"×",func():speed=s;update_time_buttons())
  tb.toggle_mode=true
  tb.set_meta("speed",s)
  time_buttons.append(tb)
 tour_button=button(controls,"Tour",func():set_tour(not tour))
 tour_button.toggle_mode=true
 button(controls,"Mondo",func():set_tour(false);following=false;focus=Vector3.ZERO;distance=91;pitch=.88;update_camera())
 for i in range(2):
  button(controls,Sim.CLANS[i],func():set_tour(false);following=false;focus=centers[i];distance=24;pitch=.72;update_camera())
 hint=text_label(controls,"WASD · rotella · destro · F6 tour",13)
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
 onboarding=panel(hud,Rect2(415,182,610,135),.97)
 var guide=VBoxContainer.new()
 onboarding.add_child(guide)
 text_label(guide,"PRIMI PASSI DEL CREATORE",15)
 onboarding_label=text_label(guide,"",16)
 onboarding_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var actions=HBoxContainer.new()
 guide.add_child(actions)
 button(actions,"Avanti",advance_onboarding)
 button(actions,"Salta guida",finish_onboarding)
 onboarding.hide()

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
 if selected_status!=null:selected_status.text="Osservazione del mondo" if a.is_empty() else str(a.get("task_stage",""))+" · "+str(a.get("activity","Decide"))
 if status_bar!=null:
  status_bar.value=sim.energy if a.is_empty() else float(a.health)
  health_fill.bg_color=Color("e1bc78") if a.is_empty() else Color("d7796c").lerp(Color("83c8a4"),float(a.health)/100)
  stats_bar.text="Energia divina · %d%%"%int(sim.energy) if a.is_empty() else "Salute · %d%%"%int(a.health)
 if mood_bar!=null:
  mood_bar.value=sim.peace if a.is_empty() else float(a.mood)
  hunger_bar.value=sim.energy if a.is_empty() else 100.0-float(a.hunger)
  mood_bar.get_parent().visible=not a.is_empty()
  hunger_bar.get_parent().visible=not a.is_empty()
  trust_bar.value=float(a.get("trust",50))
  trust_bar.get_parent().visible=not a.is_empty()
 if dialogue_view!=null:refresh_dialogue(a)
 if event_feed!=null:event_feed.text="\n".join(sim.events.slice(0,18))
 if social_summary!=null:social_summary.text="Vita sociale: %d azioni · %d aiuti · %d incontri"%[sim.social_actions,sim.aid_actions,sim.meet_actions]
 if route_status!=null:route_status.text="Carovane: %d in viaggio · %d arrivate"%[sim.shipments.size(),sim.trades]
 if a.is_empty():
  var lines=[]
  for i in range(2):
   var v=sim.villages[i]
   lines.append("%s  /  %s\n%d abitanti · %d edifici\nCibo %d · Legna %d\nFede %d%% · Scoperte %d/14\n%s\n%s"%[Sim.CLANS[i],Sim.ERAS[v.era],sim.count(i),v.houses,int(v.food),int(v.wood),int(v.faith),v.tech,v.government,v.belief])
   if int(v.project)>=0:lines.append("→ "+Sim.PROJECT_NAMES[int(v.project)]+" · "+str(int(v.progress))+"%")
  details.text="\n\n".join(lines)+"\n\nClicca una creatura per conoscerla."
 else:
  details.text=("%s%s\n%s · %s\nEtà %d · Generazione %d\nSalute %d%% · Fame %d%%\nUmore %d%% · Fede %d%%\nIntelletto %d%% · Empatia %d%%\nGenitori: %s · Partner: %s\nObiettivo: %s\n\nRICORDI\n%s"%["★ " if a.favorite else "",a.name,Sim.CLANS[a.clan],a.role,int(a.age),a.gen,int(a.health),int(a.hunger),int(a.mood),int(a.faith),int(a.genes[0]*100),int(a.genes[1]*100),family_names(a.parents),family_names([a.partner]),a.goal,"\n".join(a.memories)])
  details.text="AZIONE: "+str(a.get("activity","Decide"))+"\n"+str(a.get("task_stage",""))+" · "+str(a.get("task_reason",""))+"\nStanchezza "+str(int(a.get("fatigue",0)))+"% · Noia "+str(int(a.get("boredom",0)))+"%\nAttività concluse: "+str(a.get("tasks_done",0))+"\n\n"+details.text
  details.text+="\n\nPERSONALITÀ\n"+sim.personality(a)+"\nAmicizia: "+family_names([a.friend])
  details.text+="\nSocialità: "+str(int(a.get("social_need",0)))+"% · Esperienza: "+str(int(a.get("skill",0)))+"%"
  if int(a.get("social_target",-1))>=0:details.text+="\nIncontro: "+family_names([a.social_target])
 objective.text=["ETERNITÀ  —  Nessun limite di durata.","ALLEANZA  —  Giorno 90 · pace 70% · entrambi i popoli nell'era Regni.","OLTRE IL CIELO  —  Giorno 100 · era Contatto.","ULTIMA SCINTILLA  —  Giorno 120 · almeno 24 sopravvissuti."][sim.mode]
 if not a.is_empty() and int(a.get("intention_until",0))>sim.day:details.text+="\n\nINTENZIONE AI: "+str(a.get("intention",""))+" · fino al giorno "+str(a.intention_until)
 if sim.mode==0:
  if sim.people.is_empty():objective.text="ETERNITÀ — Mondo disabitato. Usa Vita per ricominciare."
  elif sim.legacy_cycles>0:objective.text+="  ·  Cicli del futuro: "+str(sim.legacy_cycles)
 if sim.mode==0 and not sim.active_crisis.is_empty():
  objective.text=Sim.CRISIS_NAMES[int(sim.active_crisis.kind)]+" · "+Sim.CLANS[int(sim.active_crisis.clan)]+" · fino al giorno "+str(sim.active_crisis.until)
 if sim.ended!="":objective.text=sim.ended
 chronicle.text="\n".join(sim.events.slice(0,12))
 if inspector_tabs!=null:
  var unread=sim.signals.filter(func(q):return not q.answered and not sim.find(int(q.id)).is_empty()).size()
  inspector_tabs.set_tab_title(1,"Mondo"+(" · "+str(unread) if unread>0 else ""))

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
 text_label(box,"Seme del mondo · cambia il numero per creare una nuova isola",13)
 button(box,"Seme casuale",func():seed_input.text=str(rng.randi_range(1,999999)))
 text_label(box,"Clicca per osservare · F6 tour · F1 guida · F10 cinema",13)
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
  dlg.queue_free()
  if onboarding_enabled:start_onboarding())
 dlg.canceled.connect(func():welcome_open=false;world_started=true;speed=1;update_time_buttons();dlg.queue_free();maybe_onboard())
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
  sim.record_dialogue(a,"Creatore",input.text)
  input.clear()
  refresh_dialogue(a)
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
   sim.record_dialogue(a,a.name+" · AI",reply)
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
 d["player"]={"speed":speed,"unlimited":unlimited,"selected":selected,"following":following,"tick":tick}
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
 set_tour(false)
 sim=candidate
 var advanced=0
 if absent_progress and not test_mode:
  advanced=sim.advance_absence(maxf(0,Time.get_unix_time_from_system()-float(data.get("saved_at",Time.get_unix_time_from_system()))))
 sim.spatial_autonomy=not test_mode and not benchmark_mode
 if advanced>0:
  for person in sim.people:person.task="";person.task_stage="Decide"
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
 var player=data.get("player",{})
 if not player is Dictionary:player={}
 selected=int(player.get("selected",-1))
 if not actors.has(selected):selected=-1
 following=bool(player.get("following",false)) and selected>=0
 unlimited=bool(player.get("unlimited",false))
 if is_instance_valid(unlimited_toggle):unlimited_toggle.set_pressed_no_signal(unlimited)
 show_ending=sim.ended==""
 speed=clampf(float(player.get("speed",1)),0,20)
 tick=clampf(float(player.get("tick",0)),0,1.69)
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
 if not is_instance_valid(meadow) or meadow.multimesh.instance_count<500:failed=true
 print("MEADOW_TEST instances=",meadow.multimesh.instance_count)
 var trade_test=Sim.new()
 trade_test.start(47,0)
 var food_before=float(trade_test.villages[1].food)
 trade_test.dispatch_shipment(0,12)
 if trade_test.shipments.size()!=1 or trade_test.villages[1].food!=food_before:failed=true
 var trade_copy=Sim.new()
 if not trade_copy.import_state(JSON.parse_string(JSON.stringify(trade_test.export_state()))) or trade_copy.shipments.size()!=1:failed=true
 trade_copy.day=5
 trade_copy.settle_shipments()
 if trade_copy.trades!=1 or not trade_copy.shipments.is_empty() or absf(float(trade_copy.villages[1].food)-food_before-12)>.01:failed=true
 if trade_route.size()<10:failed=true
 print("TRADE_TEST delivered=",trade_copy.trades," route_points=",trade_route.size())
 var life=Sim.new()
 life.start(91,0)
 var citizen=life.people[0]
 life.apply_reply(citizen,"Pace e amore")
 if citizen.dialogue.size()!=2 or citizen.trust<=50 or not life.rename_person(citizen,"Astra"):failed=true
 var life_copy=Sim.new()
 if not life_copy.import_state(JSON.parse_string(JSON.stringify(life.export_state()))):failed=true
 elif life_copy.people[0].name!="Astra" or life_copy.people[0].dialogue.size()!=2 or life_copy.people[0].life_story.is_empty():failed=true
 print("LIFE_TEST dialogue=",citizen.dialogue.size()," trust=",citizen.trust," biography=",citizen.life_story.size())
 var social=Sim.new()
 social.start(57,0)
 for j in range(160):social.daily()
 if social.social_actions<10 or social.meet_actions<=0:failed=true
 var aid=Sim.new()
 aid.start(47,0)
 var helper=aid.people[0]
 var patient={}
 for person in aid.people:
  if person.id!=helper.id and person.clan==helper.clan:patient=person;break
 if patient.is_empty():failed=true
 else:
  for person in aid.people:person.genes[1]=.1
  helper.genes[1]=.9
  helper.age=25
  helper.health=100
  helper.hunger=0
  helper.intention_until=0
  patient.health=48
  patient.sick=5
  patient.hunger=75
  aid.day=posmod(-int(helper.id)-1,3)
  aid.villages[helper.clan].food=200
  var control=Sim.new()
  if not control.import_state(JSON.parse_string(JSON.stringify(aid.export_state()))):failed=true
  var control_helper=control.find(int(helper.id))
  control_helper.intention_until=control.day+2
  control.daily()
  var control_patient=control.find(int(patient.id))
  aid.daily()
  if aid.aid_actions<1 or int(helper.social_target)!=int(patient.id) or not patient.has("last_aid_day") or control_patient.is_empty() or patient.health<=control_patient.health or patient.hunger>=control_patient.hunger:failed=true
  print("SOLIDARITY_CONTROL assisted=",patient.health," unassisted=",control_patient.get("health",-1)," hunger_assisted=",patient.hunger," hunger_control=",control_patient.get("hunger",-1))
  var aid_copy=Sim.new()
  if not aid_copy.import_state(JSON.parse_string(JSON.stringify(aid.export_state()))) or aid_copy.aid_actions!=aid.aid_actions:failed=true
  print("SOLIDARITY_TEST actions=",aid.aid_actions," patient_health=",patient.health," target=",helper.social_target)
 var social_clone=Sim.new()
 if not social_clone.import_state(JSON.parse_string(JSON.stringify(social.export_state()))) or social_clone.social_actions!=social.social_actions:failed=true
 print("SOCIAL_TEST actions=",social.social_actions," aid=",social.aid_actions," encounters=",social.meet_actions)
 start_onboarding()
 var guide_buttons=onboarding.find_children("*","Button",true,false)
 if guide_buttons.size()<2:failed=true
 else:
  for i in range(5):guide_buttons[0].pressed.emit()
 if onboarding.visible:failed=true
 onboarding_enabled=true
 print("ONBOARDING_TEST complete=",not onboarding.visible)
 if not test_autonomy():failed=true
 if not test_spatial_meal():failed=true
 unlimited=true
 var test_path="user://genesis47_test.json"
 if not save_path(test_path,false):failed=true
 var before=sim.people.size()
 var before_day=sim.day
 var before_trees=planted.size()
 if not load_path(test_path) or sim.people.size()!=before or sim.day!=before_day or planted.size()!=before_trees or not unlimited:failed=true
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
 button(box,"Come misurare gli FPS",func():open_dialog("BENCHMARK","Chiudi il gioco e apri BENCHMARK.bat nella cartella del gioco. Misura i tre profili in una partita separata e crea un rapporto sul tuo PC."))
 button(box,"Scheda prova giocatore",show_playtest)
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
 dlg.popup_centered(Vector2i(470,360))

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

func spawn_caravan(id:int):
 if not is_instance_valid(villages_root):return
 for row in caravans:
  if row.id==id:return
 for shipment in sim.shipments:
  if int(shipment.id)!=id:continue
  var n=asset(villages_root,"cart",int(shipment.clan),centers[int(shipment.clan)],.88)
  if n==null:return
  caravans.append({"node":n,"id":id})
  update_caravans(0)
  return

func remove_caravan(id:int):
 for row in caravans.duplicate():
  if int(row.id)==id:
   if is_instance_valid(row.node):row.node.queue_free()
   caravans.erase(row)

func update_caravans(_delta:float):
 if trade_route.size()<2:return
 for row in caravans.duplicate():
  if not is_instance_valid(row.node):
   caravans.erase(row)
   continue
  var shipment={}
  for current in sim.shipments:
   if int(current.id)==int(row.id):shipment=current;break
  if shipment.is_empty():
   remove_caravan(int(row.id))
   continue
  var f=clampf((float(sim.day-shipment.depart)+clampf(tick/1.7,0,.99))/maxf(1,float(shipment.due-shipment.depart)),0,1)
  if int(shipment.clan)==1:f=1-f
  var index=clampf(f*(trade_route.size()-1),0,trade_route.size()-1.001)
  var i=int(index)
  var pos=trade_route[i].lerp(trade_route[i+1],index-i)
  row.node.position=pos+Vector3.UP*.05
  var dir=trade_route[i+1]-trade_route[i]
  if int(shipment.clan)==1:dir=-dir
  row.node.rotation.y=atan2(dir.x,dir.z)

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
 onboarding_enabled=bool(settings.get_value("game","onboarding",true))
 absent_progress=bool(settings.get_value("game","absence",false))
 ai_autonomy=bool(settings.get_value("game","ai_autonomy",true))
 volume_value=float(settings.get_value("game","volume",50))
 audio.volume_db=linear_to_db(maxf(.001,volume_value/100.0))-17
 audio.stream_paused=bool(settings.get_value("game","muted",false))

func store_settings():
 settings.set_value("game","quality",quality_mode)
 settings.set_value("game","autosave",autosave_enabled)
 settings.set_value("game","onboarding",onboarding_enabled)
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

func small_meter(parent:Node,caption:String,tint:Color)->ProgressBar:
 var row=HBoxContainer.new()
 parent.add_child(row)
 var lbl=text_label(row,caption,12)
 lbl.custom_minimum_size.x=64
 var bar=ProgressBar.new()
 bar.custom_minimum_size=Vector2(0,10)
 bar.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 bar.size_flags_vertical=Control.SIZE_SHRINK_CENTER
 bar.show_percentage=false
 bar.max_value=100
 var style=StyleBoxFlat.new()
 style.bg_color=tint
 style.set_corner_radius_all(4)
 bar.add_theme_stylebox_override("fill",style)
 row.add_child(bar)
 return bar

func show_crisis_history():
 var lines=[]
 for event in sim.crisis_history:
  lines.append("Giorno %d · %s · %s"%[int(event.day),Sim.CLANS[int(event.clan)],Sim.CRISIS_NAMES[int(event.kind)]])
 open_dialog("STORIA DELLE CRISI","\n".join(lines) if not lines.is_empty() else "Nessuna crisi storica. Il mondo è ancora giovane.")

func away_from_route(p:Vector3,radius:float)->bool:
 for q in trade_route:
  if Vector2(p.x-q.x,p.z-q.z).length()<radius:return false
 return true

func route_beam(parent:Node3D,a:Vector3,b:Vector3,width:float,height:float,tint:Color):
 var delta=b-a
 if delta.length()<.01:return
 var beam=block(parent,tint,(a+b)*.5,Vector3(width,height,delta.length()+.04))
 beam.look_at(b,Vector3.UP)

func rebuild_trade_route():
 if not is_instance_valid(route_root) or centers.size()!=2:return
 for n in route_root.get_children():
  route_root.remove_child(n)
  n.queue_free()
 trade_route.clear()
 var start:Vector3=centers[0]
 var finish:Vector3=centers[1]
 var direction=Vector2(finish.x-start.x,finish.z-start.z).normalized()
 var normal=direction.orthogonal()
 for i in range(65):
  var f=float(i)/64.0
  var q=start.lerp(finish,f)
  q.x+=normal.x*sin(f*PI)*2.0
  q.z+=normal.y*sin(f*PI)*2.0
  q.y=maxf(height_at(q.x,q.z)+.15,SEA+.62)
  trade_route.append(q)
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(trade_route.size()-1):
  var a=trade_route[i]
  var b=trade_route[i+1]
  var tangent=Vector2(b.x-a.x,b.z-a.z).normalized().orthogonal()*.58
  var side=Vector3(tangent.x,0,tangent.y)
  var wet=height_at(a.x,a.z)<SEA+.55 or height_at(b.x,b.z)<SEA+.55
  if wet:
   route_beam(route_root,a-Vector3.UP*.10,b-Vector3.UP*.10,1.20,.18,Color("96734c"))
   for sign_value in [-1,1]:
    route_beam(route_root,a+side*sign_value+Vector3.UP*.32,b+side*sign_value+Vector3.UP*.32,.07,.09,Color("5e4c36"))
    if i%2==0:block(route_root,Color("6b5239"),a+side*sign_value+Vector3.UP*.13,Vector3(.10,.65,.10))
   if i%3==0:
    var floor_y=height_at(a.x,a.z)
    for sign_value in [-1,1]:
     var h=maxf(.35,a.y-floor_y)
     block(route_root,Color("6e6555"),Vector3(a.x,floor_y+h*.5,a.z)+side*sign_value*.78,Vector3(.17,h,.17))
  else:
   var aa=a+side
   var ab=a-side
   var ba=b+side
   var bb=b-side
   for v in [aa,ab,ba,ab,bb,ba]:
    v.y=height_at(v.x,v.z)+.13
    st.add_vertex(v)
 st.generate_normals()
 var mesh=st.commit()
 if mesh!=null:
  var mi=MeshInstance3D.new()
  mi.mesh=mesh
  var mat=ShaderMaterial.new()
  mat.shader=path_shader
  mi.material_override=mat
  mi.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  route_root.add_child(mi)

func follow_person(id:int):
 if not actors.has(id):return
 selected=id
 power="Osserva"
 following=true
 focus=actors[id].node.position
 distance=4.2
 pitch=.43
 if is_instance_valid(inspector_tabs):inspector_tabs.current_tab=0
 update_camera()
 refresh()

func refresh_dialogue(a:Dictionary):
 if not is_instance_valid(dialogue_view):return
 dialogue_heading.text="PARLA CON LA VITA" if a.is_empty() else "DIALOGO · "+str(a.name)
 var lines=[]
 if a.is_empty():
  dialogue_view.text="Seleziona un abitante per conversare oppure scrivi un messaggio a tutto il mondo."
  return
 for entry in a.get("dialogue",[]):
  lines.append("G%d · %s\n%s"%[int(entry.day),str(entry.speaker),str(entry.text)])
 dialogue_view.text="\n\n".join(lines) if not lines.is_empty() else "Non avete ancora parlato. Scrivi il tuo primo messaggio."

func show_biography():
 var a=sim.find(selected)
 if a.is_empty():
  hint.text="Seleziona un abitante."
  return
 var lines=[a.name+" · "+sim.personality(a),"Generazione "+str(a.gen)+" · Fiducia nel Creatore "+str(int(a.get("trust",50)))+"%",""]
 for event in a.get("life_story",[]):lines.append("Giorno %d · %s\n%s"%[int(event.day),event.kind,event.text])
 open_dialog("BIOGRAFIA","\n\n".join(lines))

func show_family():
 var a=sim.find(selected)
 if a.is_empty():
  hint.text="Seleziona un abitante."
  return
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title="LEGAMI DI "+str(a.name)
 var box=VBoxContainer.new()
 dlg.add_child(box)
 var links=[]
 for id in a.parents:links.append({"id":int(id),"kind":"Genitore"})
 if a.partner>=0:links.append({"id":int(a.partner),"kind":"Partner"})
 if a.friend>=0:links.append({"id":int(a.friend),"kind":"Amico"})
 for child in sim.people:
  if child.parents.has(a.id):links.append({"id":int(child.id),"kind":"Figlio"})
 var scroll=ScrollContainer.new()
 scroll.custom_minimum_size=Vector2(420,260)
 box.add_child(scroll)
 var list=VBoxContainer.new()
 list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.add_child(list)
 for link in links:
  var id=int(link.id)
  var b=button(list,str(link.kind)+" · "+family_names([id]),func():follow_person(id);dlg.hide();dlg.queue_free())
  b.disabled=not actors.has(id)
 if links.is_empty():text_label(list,"Nessun legame registrato.")
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(470,350))

func rename_selected():
 var a=sim.find(selected)
 if a.is_empty():
  hint.text="Seleziona un abitante."
  return
 var dlg=ConfirmationDialog.new()
 hud.add_child(dlg)
 dlg.title="RINOMINA ABITANTE"
 var field=LineEdit.new()
 field.max_length=24
 field.text=a.name
 field.custom_minimum_size.x=340
 dlg.add_child(field)
 dlg.confirmed.connect(func():sim.rename_person(a,field.text);refresh();dlg.queue_free())
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(390,130))

func rebuild_settlement_details():
 if not is_instance_valid(settlement_root) or centers.size()!=2:return
 for child in settlement_root.get_children():
  settlement_root.remove_child(child)
  child.queue_free()
 for i in range(2):
  var v=sim.villages[i]
  if int(v.era)<2:continue
  var p=land_near(centers[i].x+(3.0 if i==0 else -3.0),centers[i].z+2.5)
  var market=Node3D.new()
  settlement_root.add_child(market)
  market.position=p
  market.rotation.y=.3 if i==0 else -.3
  var cloth=Color("6ba69f") if i==0 else Color("ce9866")
  for stall in range(2):
   var n=Node3D.new()
   market.add_child(n)
   n.position=Vector3(stall*1.4-.7,0,0)
   block(n,Color("806448"),Vector3(0,.40,0),Vector3(1.1,.15,.62))
   for side in [-1,1]:
    for z in [-1,1]:
     block(n,Color("987857"),Vector3(side*.48,.59,z*.28),Vector3(.07,1.18,.07))
   block(n,cloth,Vector3(0,1.18,0),Vector3(1.23,.12,.76))
   for k in range(5):
    if k%2==0:block(n,Color("e8d7ac"),Vector3((k-2)*.24,1.25,0),Vector3(.13,.025,.76))
   for k in range(4):
    sphere(n,Color("d9ad53") if k%2==0 else Color("9bac65"),Vector3((k-1.5)*.21,.57,.02),Vector3(.17,.17,.17))
  for j in range(5):
   var q=Vector3((j-2)*.35,.12,1.0)
   cone(market,Color("8c7052"),q,.13,.23,.15,8)
   sphere(market,Color("9db86e"),q+Vector3.UP*.18,Vector3(.26,.24,.26))

func set_tour(on:bool):
 tour=on
 if is_instance_valid(tour_button):tour_button.set_pressed_no_signal(on)
 if on:
  tour_clock=0.0
  tour_index=-1
  following=false
  selected=-1
  power="Osserva"
  refresh()
  if is_instance_valid(power_category):populate_powers(power_category.selected)

func update_tour(delta:float):
 if centers.size()!=2:return
 tour_clock-=delta
 if tour_clock<=0:
  tour_clock=12.0
  tour_index=(tour_index+1)%4
 var target=Vector3.ZERO
 var zoom=70.0
 var tilt=.85
 if tour_index in [1,2]:
  target=centers[tour_index-1]
  zoom=17.0
  tilt=.59
 elif tour_index==3 and not trade_route.is_empty():
  target=trade_route[int(trade_route.size()/2.0)]
  zoom=28.0
  tilt=.65
 focus=focus.lerp(target,clampf(delta*.65,0,1))
 distance=lerpf(distance,zoom,clampf(delta*.55,0,1))
 pitch=lerpf(pitch,tilt,clampf(delta*.55,0,1))
 azimuth+=delta*.045
 update_camera()

func rebuild_meadow():
 if is_instance_valid(meadow):
  remove_child(meadow)
  meadow.queue_free()
 var blade=SurfaceTool.new()
 blade.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in range(5):
  var angle=float(j)*2.39996
  var offset=Vector3(cos(angle)*.11,0,sin(angle)*.11)
  var tangent=Vector3(cos(angle),0,sin(angle))*.028
  var tip=offset*1.8+Vector3.UP*(.19+.045*(j%3))
  for v in [offset-tangent,offset+tangent,tip]:blade.add_vertex(v)
 blade.generate_normals()
 var mesh=blade.commit()
 var mat=ShaderMaterial.new()
 mat.shader=preload("res://shaders/meadow.gdshader")
 mesh.surface_set_material(0,mat)
 var transforms:Array[Transform3D]=[]
 var local=RandomNumberGenerator.new()
 local.seed=sim.seed_value+734
 for i in range(12500):
  if transforms.size()>=4200:break
  var p=ground(local.randf_range(-49,49),local.randf_range(-49,49))
  if p.y<SEA+.7 or p.y>7.3 or not far_village(p,4.0) or not away_from_route(p,.8):continue
  var scale_value=local.randf_range(.55,1.35)
  var basis=Basis(Vector3.UP,local.randf()*TAU).scaled(Vector3.ONE*scale_value)
  transforms.append(Transform3D(basis,p))
 var mm=MultiMesh.new()
 mm.transform_format=MultiMesh.TRANSFORM_3D
 mm.mesh=mesh
 mm.instance_count=transforms.size()
 for i in range(transforms.size()):mm.set_instance_transform(i,transforms[i])
 meadow=MultiMeshInstance3D.new()
 meadow.multimesh=mm
 meadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(meadow)

func maybe_onboard():
 if onboarding_enabled:start_onboarding()

func start_onboarding():
 if not is_instance_valid(onboarding):return
 onboarding_step=0
 onboarding.show()
 show_onboarding_step()

func show_onboarding_step():
 var steps=["1/5 · Sposta la vista con WASD, ruota tenendo premuto il destro e usa la rotella per avvicinarti.","2/5 · Clicca una creatura per conoscerla. Un doppio clic la segue; puoi anche usare Casuale e Segui.","3/5 · A sinistra scegli Vita o Guarigione, poi clicca sul terreno. Osserva annulla il potere.","4/5 · A destra, Mondo mostra civiltà, scoperte e segnali. Dialogo permette di parlare con un abitante.","5/5 · Usa Pausa e le velocità in basso. F5 salva, F9 carica, F6 avvia il tour. In Eternità non devi vincere."]
 onboarding_label.text=steps[clampi(onboarding_step,0,4)]

func advance_onboarding():
 onboarding_step+=1
 if onboarding_step>=5:finish_onboarding()
 else:show_onboarding_step()

func finish_onboarding():
 onboarding.hide()
 onboarding_enabled=false
 if not test_mode:store_settings()

func rebuild_landmarks():
 if not is_instance_valid(landmark_root) or centers.size()!=2:return
 for child in landmark_root.get_children():
  landmark_root.remove_child(child)
  child.queue_free()
 village_lights.clear()
 for i in range(2):
  if sim.villages[i].era<1:continue
  var tint=Color("60c3ac") if i==0 else Color("e5ae73")
  var center=centers[i]
  for j in range(4):
   var angle=float(j)*TAU/4+.4
   var point=ground(center.x+cos(angle)*3.4,center.z+sin(angle)*3.4)
   if point.y<SEA+.2:continue
   var n=Node3D.new()
   landmark_root.add_child(n)
   n.position=point
   cone(n,Color("777d70"),Vector3.UP*.12,.35,.24,.27,8)
   cone(n,Color("465c55"),Vector3.UP*.64,.075,1.1,.055,8)
   cone(n,tint,Vector3.UP*1.24,.19,.30,.035,8,.45)
   if j==0 or j==2:
    var l=OmniLight3D.new()
    n.add_child(l)
    l.position.y=1.25
    l.light_color=tint
    l.omni_range=3.0
    l.light_energy=.25
    village_lights.append(l)
  var point=ground(center.x+2.6,center.z-2.6)
  if point.y>SEA+.2:
   var monument=Node3D.new()
   landmark_root.add_child(monument)
   monument.position=point
   cone(monument,Color("a6a895"),Vector3.UP*.1,.66,.2,.58,10)
   cone(monument,Color("687e70"),Vector3.UP*.55,.36,.7,.25,7)
   cone(monument,tint,Vector3.UP*1.16,.29,.55,.02,7,.3)

func creature_skin(c:Color)->ShaderMaterial:
 # Quantize only the procedural skin palette to limit material allocations.
 var q=Color(roundf(c.r*24)/24.0,roundf(c.g*24)/24.0,roundf(c.b*24)/24.0)
 var key=q.to_html(false)
 if not skin_cache.has(key):
  var m=ShaderMaterial.new()
  m.shader=preload("res://shaders/creature_skin.gdshader")
  m.set_shader_parameter("skin_color",q)
  skin_cache[key]=m
 return skin_cache[key]

func run_benchmark():
 if DisplayServer.get_name()=="headless":
  print("BENCHMARK_REQUIRES_GRAPHICS")
  get_tree().quit(1)
  return
 var short_test="--benchmark-test" in OS.get_cmdline_user_args()
 autosave_enabled=false
 Engine.max_fps=0
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 speed=0
 for i in range(125):sim.daily()
 apply_changes()
 for i in range(2):sync_houses(i)
 var info={"version":"2.0.0","cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"driver":RenderingServer.get_video_adapter_api_version(),"window":str(DisplayServer.window_get_size()),"population":sim.people.size(),"seed":47,"day":sim.day,"profiles":[]}
 var names=["Prestazioni","Bilanciata","Qualita"]
 for profile in range(3):
  apply_quality(profile)
  var samples:Array[float]=[]
  for shot in range(3):
   focus=Vector3.ZERO if shot==0 else centers[shot-1]
   distance=65.0 if shot==0 else 19.0
   pitch=.78 if shot==0 else .55
   update_camera()
   await get_tree().create_timer(.4 if short_test else 1.5).timeout
   var start=Time.get_ticks_usec()
   var previous=start
   var duration=300000 if short_test else 5000000
   while Time.get_ticks_usec()-start<duration:
    await RenderingServer.frame_post_draw
    var now=Time.get_ticks_usec()
    samples.append(float(now-previous)/1000.0)
    previous=now
    azimuth+=.008
    update_camera()
  if samples.is_empty():
   get_tree().quit(1)
   return
  samples.sort()
  var total=0.0
  for frame in samples:total+=frame
  var mean_ms=total/samples.size()
  var p99=samples[clampi(ceili(samples.size()*.99)-1,0,samples.size()-1)]
  info.profiles.append({"name":names[profile],"fps_average":snappedf(1000/maxf(.01,mean_ms),.1),"fps_p99_equivalent":snappedf(1000/maxf(.01,p99),.1),"frames":samples.size()})
 var file=FileAccess.open("user://benchmark-genesis47.json",FileAccess.WRITE)
 if file==null:
  get_tree().quit(1)
  return
 file.store_string(JSON.stringify(info,"  "))
 file.close()
 print("BENCHMARK_COMPLETE ",JSON.stringify(info))
 if not short_test:OS.shell_open(ProjectSettings.globalize_path("user://"))
 get_tree().quit()

func show_playtest():
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title="PROVA CON UN GIOCATORE"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 text_label(box,"Fai provare il gioco a una persona che non lo conosce. Senza suggerimenti.",16).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var tasks=["Creare un mondo Eternità","Selezionare e seguire un abitante","Usare Guarigione","Inviare un messaggio","Salvare e ricaricare","Cambiare qualità grafica"]
 var checks:Array=[]
 for task in tasks:
  var check=CheckBox.new()
  check.text=task
  box.add_child(check)
  checks.append(check)
 text_label(box,"Commenti: difficoltà, bug, cosa non era chiaro",14)
 var notes=TextEdit.new()
 notes.custom_minimum_size=Vector2(510,100)
 box.add_child(notes)
 button(box,"Salva rapporto locale",func():
  var results={}
  for i in range(tasks.size()):results[tasks[i]]=checks[i].button_pressed
  var record={"version":"2.0.0","date":Time.get_datetime_string_from_system(),"tasks_completed_without_help":results,"notes":notes.text}
  var path="user://playtest-"+str(Time.get_unix_time_from_system()).replace(".","-")+".json"
  var f=FileAccess.open(path,FileAccess.WRITE)
  if f!=null:
   f.store_string(JSON.stringify(record,"  "))
   f.close()
   OS.shell_open(ProjectSettings.globalize_path("user://"))
  dlg.hide()
  dlg.queue_free())
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(560,470))

func walking_height(x:float,z:float)->float:
 var h=height_at(x,z)
 if h<SEA+.55:
  for p in trade_route:
   if Vector2(x-p.x,z-p.z).length()<.65:return maxf(h,p.y)
 return h

func rebuild_navigation():
 nav_grid.region=Rect2i(-50,-50,101,101)
 nav_grid.cell_size=Vector2.ONE
 nav_grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 nav_grid.update()
 nav_grid.fill_solid_region(nav_grid.region,false)
 for z in range(-50,51):
  for x in range(-50,51):
   var h=walking_height(x,z)
   if h<SEA+.18:
    nav_grid.set_point_solid(Vector2i(x,z))
 for clan in range(2):
  for home in houses[clan]:
   var q:Vector3=home.node.position
   for z in range(floori(q.z-1.3),ceili(q.z+1.3)+1):
    for x in range(floori(q.x-1.3),ceili(q.x+1.3)+1):
     var cell=Vector2i(x,z)
     if nav_grid.region.has_point(cell) and Vector2(x-q.x,z-q.z).length()<1.3:nav_grid.set_point_solid(cell)
 nav_dirty=false
 nav_version+=1

func near_cell(p:Vector3)->Vector2i:
 var base=Vector2i(roundi(p.x),roundi(p.z))
 var best=Vector2i(999,999)
 var cost=INF
 for z in range(base.y-4,base.y+5):
  for x in range(base.x-4,base.x+5):
   var cell=Vector2i(x,z)
   if not nav_grid.region.has_point(cell) or nav_grid.is_point_solid(cell):continue
   var dist=Vector2(x-p.x,z-p.z).length_squared()
   if dist<cost:cost=dist;best=cell
 return best

func task_destination(a:Dictionary)->Vector3:
 var c:Vector3=centers[a.clan]
 var angle=float(int(a.id)%12)*TAU/12
 var offset=Vector3(cos(angle),0,sin(angle))
 match a.task:
  "sleep","heal":
   var h=house_location(a.clan,int(a.id)%maxi(1,houses[a.clan].size()))
   return h+(c-h).normalized()*2.0
  "eat":return c+offset*2.1
  "farm":
   if not farm_points[a.clan].is_empty():return farm_points[a.clan][int(a.id)%farm_points[a.clan].size()]+offset*.6
   return c+Vector3(3,0,4)+offset
  "gather":
   var nearest=c+offset*9.0
   var best=INF
   var origin=c+offset*6.0
   for tree_point in timber_points:
    var q:Vector3=tree_point
    var cost=q.distance_squared_to(origin)
    if cost<best:best=cost;nearest=q+(c-q).normalized()*.8
   return nearest
  "research":return c+Vector3(-2,0,-2)+offset
  "build":return c+Vector3(2,0,-3)+offset
  "social","aid":
   if actors.has(int(a.task_target)):return actors[int(a.task_target)].node.position+offset*.7
   return c+offset*2
  "play":return c+Vector3(-3,0,3)+offset
  "explore":return c+Vector3(cos(angle+float(a.tasks_done)*1.7),0,sin(angle+float(a.tasks_done)*1.7))*8.0
 return c+offset

func route_actor(a:Dictionary,r:Dictionary)->bool:
 var n:Node3D=r.node
 var start=near_cell(n.position)
 var finish=near_cell(task_destination(a))
 if not nav_grid.region.has_point(start) or not nav_grid.region.has_point(finish):return false
 var ids=nav_grid.get_id_path(start,finish)
 if ids.is_empty():return false
 var points:Array=[]
 for cell in ids:
  points.append(Vector3(cell.x,walking_height(cell.x,cell.y),cell.y))
 r.route=points
 r.route_index=0
 r.planned_task=a.task
 r.nav_version=nav_version
 r.travel_time=0.0
 return true

func cancel_task(a:Dictionary,r:Dictionary):
 a.last_task=a.task
 a.task=""
 a.task_stage="Decide"
 a.task_target=-1
 a.social_target=-1
 a.task_left=0
 r.planned_task=""
 r.route=[]
 r.retry=1.0

func advance_actor_task(a:Dictionary,r:Dictionary,dt:float)->bool:
 var n:Node3D=r.node
 if dt<=0:return false
 if sim.spatial_autonomy:sim.tick_needs(a,dt)
 if float(r.get("retry",0))>0:
  r.retry=maxf(0,float(r.retry)-dt)
  return false
 if a.task!="" and a.task not in ["eat","sleep","heal"] and (a.hunger>=91 and sim.villages[a.clan].food>=1 or a.fatigue>=94 or a.health<35):
  cancel_task(a,r)
  return false
 if a.task=="":
  sim.begin_task(a,sim.choose_task(a))
 if a.task in ["social","aid"] and not actors.has(int(a.task_target)):
  cancel_task(a,r)
  return false
 if str(r.get("planned_task",""))!=a.task or int(r.get("nav_version",-1))!=nav_version:
  if not route_actor(a,r):
   cancel_task(a,r)
   return false
  a.task_stage="In viaggio"
 if int(r.route_index)<r.route.size():
  var destination:Vector3=r.route[int(r.route_index)]
  var diff=destination-n.position
  diff.y=0
  var budget=dt*2.7*lerpf(.8,1.2,float(a.genes[3]))
  while int(r.route_index)<r.route.size():
   destination=r.route[int(r.route_index)]
   diff=destination-n.position
   diff.y=0
   if diff.length()>budget:
    if budget>0:
     var point=n.position+diff.normalized()*budget
     point.y=walking_height(point.x,point.z)
     n.position=point
     n.rotation.y=lerp_angle(n.rotation.y,atan2(diff.x,diff.z),minf(dt*8,1))
    break
   n.position=destination
   budget-=diff.length()
   r.route_index+=1
  if int(r.route_index)<r.route.size():return true
 if a.task in ["social","aid"]:
  var partner:Node3D=actors[int(a.task_target)].node
  if Vector2(n.position.x-partner.position.x,n.position.z-partner.position.z).length()>2.0:
   r["social_retry"]=float(r.get("social_retry",0))+dt
   if float(r.social_retry)>9:
    r.social_retry=0.0
    cancel_task(a,r)
   else:
    r["repath_wait"]=float(r.get("repath_wait",0))+dt
    if r.repath_wait>=.65:
     r.repath_wait=0.0
     r.planned_task=""
   return false
  r.social_retry=0.0
  r["repath_wait"]=0.0
 a.task_stage="In corso"
 a.task_left=maxf(0,float(a.task_left)-dt)
 if a.task_left<=0:
  if sim.spatial_autonomy:sim.complete_task(a)
  else:a.task=""
  r.planned_task=""
  r.retry=.35
 return false

func test_autonomy()->bool:
 var sample=Sim.new()
 sample.start(47,0)
 var citizen=sample.people[0]
 citizen.hunger=98.0
 citizen.fatigue=10.0
 citizen.health=100.0
 citizen.boredom=0.0
 var plan=sample.choose_task(citizen)
 if plan.kind!="eat":return false
 sample.begin_task(citizen,plan)
 var food=float(sample.villages[0].food)
 if citizen.hunger!=98 or sample.villages[0].food!=food:return false
 if not sample.complete_task(citizen) or citizen.hunger>=40 or sample.villages[0].food!=food-1:return false
 citizen.hunger=0
 citizen.fatigue=98
 if sample.choose_task(citizen).kind!="sleep":return false
 sample.begin_task(citizen,sample.choose_task(citizen))
 var copy=Sim.new()
 if not copy.import_state(JSON.parse_string(JSON.stringify(sample.export_state()))) or copy.people[0].task!="sleep":return false
 rebuild_navigation()
 var start=near_cell(centers[0]+Vector3(2,0,0))
 var finish=near_cell(centers[0]+Vector3(-2,0,0))
 if not nav_grid.region.has_point(start) or not nav_grid.region.has_point(finish):return false
 var path=nav_grid.get_id_path(start,finish)
 if path.size()<2:return false
 for cell in path:
  if nav_grid.is_point_solid(cell):return false
 print("AUTONOMY_TEST priority=eat,sleep path=",path.size()," persistent_task=",copy.people[0].task)
 return true

func test_spatial_meal()->bool:
 deformation.clear()
 new_world(47,0)
 sim.spatial_autonomy=true
 rebuild_navigation()
 var a=sim.people[0]
 var r=actors[a.id]
 var n:Node3D=r.node
 a.hunger=95.0
 a.fatigue=0.0
 a.health=100.0
 a.boredom=0.0
 var origin=near_cell(centers[0]+Vector3(7,0,2))
 if not nav_grid.region.has_point(origin):return false
 n.position=Vector3(origin.x,walking_height(origin.x,origin.y),origin.y)
 var initial=n.position
 var food=float(sim.villages[0].food)
 advance_actor_task(a,r,.1)
 if a.task!="eat" or a.tasks_done!=0 or sim.villages[0].food!=food:return false
 sim.daily()
 if a.task!="eat":return false
 var travelled=false
 var worked=false
 var food_after_day=float(sim.villages[0].food)
 for i in range(300):
  advance_actor_task(a,r,.1)
  if n.position.distance_to(initial)>1.0:travelled=true
  if a.task_stage=="In corso":worked=true
  if a.tasks_done>0:break
  if sim.villages[0].food!=food_after_day:return false
 var passed=travelled and worked and a.tasks_done==1 and a.last_task=="eat" and a.hunger<50 and absf(float(sim.villages[0].food)-food_after_day+1)<.01
 print("SPATIAL_MEAL_TEST ",passed," travelled=",travelled," worked=",worked," hunger=",a.hunger," completed=",a.tasks_done)
 sim.spatial_autonomy=false
 return passed
