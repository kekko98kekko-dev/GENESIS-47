extends Node3D
const Sim=preload("res://scripts/sim.gd")
const Ocean=preload("res://scripts/ocean.gd")
const CreatureRig=preload("res://scripts/creature_rig.gd")
const DebrisPhysics=preload("res://scripts/debris_physics.gd")
const Hydro=preload("res://scripts/hydrology.gd")
const FluidVolume=preload("res://scripts/fluid_volume.gd")
const OceanDynamics=preload("res://scripts/ocean_dynamics.gd")
const QualityAssurance=preload("res://scripts/quality_assurance.gd")
const MotionLibrary=preload("res://scripts/mocap_library.gd")
const Structure=preload("res://scripts/structure.gd")
const Art=preload("res://scripts/art_direction.gd")
const Legend=preload("res://scripts/legend.gd")
const Wildlife=preload("res://scripts/wildlife.gd")
const LivingScore=preload("res://scripts/living_score.gd")
const Frontier=preload("res://scripts/frontier.gd")
const Districts=preload("res://scripts/civic_districts.gd")
const Origins=preload("res://scripts/origins.gd")
const Cave=preload("res://scripts/cave_exploration.gd")
const Rivers=preload("res://scripts/river_system.gd")
const Legacy=preload("res://scripts/legacy_society.gd")
const LivingArt=preload("res://scripts/living_art.gd")
const SEA=-0.40
const GRID=116
const STEP=0.912
const POWERS=["Osserva","Vita","Foresta","Provviste","Guarigione","Meteorite","Conoscenza","Pace","Mutazione","Pioggia","Conflitto","Fede","Fulmine","Tsunami","Vulcano","Resurrezione","Montagna","Lago","Profeta","Nuova specie","Carestia","Incendio","Terremoto","Tornado","Epidemia"]
const SAVE_PREFIX="user://genesis47_slot"
var sim=Sim.new()
var ocean=Ocean.new()
var debris=DebrisPhysics.new()
var hydro=Hydro.new()
var fluid_volume=FluidVolume.new()
var ocean_dynamics=OceanDynamics.new()
var ocean_dynamics_saved={}
var fluid_saved={}
var fluid_root:Node3D
var legend=Legend.new()
var districts=Districts.new()
var origins=Origins.new()
var legacy=Legacy.new()
var legacy_root:Node3D
var legacy_view:RichTextLabel
var citizen_portrait:Control
var title_intro:Control
var intro_time=0.0
var ash_time=0.0
var cave=Cave.new()
var rivers=Rivers.new()
var cave_root:Node3D
var river_root:Node3D
var river_saved={}
var cave_saved={}
var vast_world=false
var frontier_root:Node3D
var district_root:Node3D
var origin_root:Node3D
var wildlife=Wildlife.new()
var living_score=LivingScore.new()
var legend_root:Node3D
var wildlife_root:Node3D
var legend_view:RichTextLabel
var journey_label:Label
var map_panel:PanelContainer
var map_region:Label
var player_hud=true
var impact_shake=0.0
var impact_flash:ColorRect
var hydro_root:Node3D
var hydro_saved={}
var colony_selected=-1
var ocean_root:Node3D
var physics_root:Node3D
var market_view:RichTextLabel
var expanded_world=false
var regional_root:Node3D
var culture_view:RichTextLabel
const REGION_NAMES=["Isola delle origini","Isola del vento","Isola dell’alba"]
const REGION_POINTS=[Vector2.ZERO,Vector2(-43,-39),Vector2(43,39)]
const REGION_BRIDGES=[[Vector2(-27,-24),Vector2(-43,-39)],[Vector2(27,24),Vector2(43,39)]]
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
var house_sites:Array=[[],[]]
var service_root:Node3D
var services:Dictionary={}
var claims:Dictionary={}
var services_dirty=true
var completed_visible=0
var life_overlay:Label
var show_world_labels=false
var discovery_sites:Array=[]
var discovery_root:Node3D
var hazard_root:Node3D
var hazards:Array=[]
var hazard_nodes:Dictionary={}
var next_hazard=1
var hazard_tick=0.0
var society_tick=0.0
var battle_count=0
var outposts:Array=[]
var outpost_root:Node3D
var ruins:Array=[]
var scars:Array=[]
var ruin_root:Node3D
var destroyed_total=0
var world_centers:Array=[]
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
var absent_progress=false
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
const GROUPS=[["Osserva","Vita","Foresta","Provviste","Guarigione","Pioggia","Resurrezione"],["Conoscenza","Pace","Fede","Profeta","Mutazione","Nuova specie"],["Meteorite","Conflitto","Fulmine","Tsunami","Vulcano","Carestia","Incendio","Terremoto","Tornado","Epidemia"],["Montagna","Lago"]]
const POWER_TIPS={"Osserva":"Seleziona un abitante senza modificarlo.","Vita":"Crea un abitante nel popolo più vicino.","Foresta":"Pianta alberi e aggiunge legna.","Provviste":"Aggiunge 100 unità di cibo.","Guarigione":"Ripristina salute e cura malattie in un raggio di 6 m.","Pioggia":"Aumenta le risorse alimentari.","Resurrezione":"Riporta in vita un abitante defunto.","Conoscenza":"Accelera la ricerca del popolo.","Pace":"Migliora le relazioni fra le civiltà.","Fede":"Aumenta la fiducia nel Creatore.","Profeta":"Ispira un profeta persistente.","Mutazione":"Cambia i tratti genetici degli abitanti vicini.","Nuova specie":"Genera un individuo con tratti casuali.","Meteorite":"Danneggia la zona e scava un cratere.","Conflitto":"Riduce la pace fra i popoli.","Fulmine":"Colpisce gli abitanti nelle vicinanze.","Tsunami":"Danneggia abitanti e scorte.","Vulcano":"Solleva il terreno e scatena un'eruzione.","Carestia":"Riduce le scorte alimentari.","Montagna":"Solleva il terreno.","Lago":"Abbassa il terreno."}

func _ready():
 benchmark_mode="--benchmark" in OS.get_cmdline_user_args() or "--benchmark-test" in OS.get_cmdline_user_args()
 test_mode="--self-test" in OS.get_cmdline_user_args() or "--qa-test" in OS.get_cmdline_user_args()
 load_catalog()
 setup_environment()
 setup_ui()
 if not test_mode and not benchmark_mode and not "--capture" in OS.get_cmdline_user_args():restore_settings()
 new_world(47,0)
 if "--qa-test" in OS.get_cmdline_user_args():
  call_deferred("run_quality_assurance")
 elif test_mode:
  call_deferred("self_test")
 elif benchmark_mode:
  autosave_enabled=false
  call_deferred("run_benchmark")
 elif "--capture" in OS.get_cmdline_user_args():
  call_deferred("capture_preview")
 else:
  get_tree().auto_accept_quit=false
  show_title_screen()

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
 env.fog_density=.0013
 env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
 env.tonemap_exposure=.83
 env.adjustment_enabled=true
 env.adjustment_saturation=1.14
 env.adjustment_contrast=1.04
 var en=WorldEnvironment.new()
 en.environment=env
 add_child(en)
 sun=DirectionalLight3D.new()
 add_child(sun)
 sun.rotation_degrees=Vector3(-53,-37,0)
 sun.light_color=Color("fff0cc")
 sun.light_energy=.76
 sun.shadow_enabled=true
 sun.directional_shadow_max_distance=115
 sun.shadow_bias=.045
 sun.shadow_normal_bias=.9
 camera=Camera3D.new()
 add_child(camera)
 camera.current=true
 camera.fov=45
 camera.far=450
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
  living_score.setup(self)

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
 if ocean.enabled:
  h=minf(h,10.5*(.82-d)-.35)
  for i in range(1,REGION_POINTS.size()):
   var island_distance=Vector2(x,z).distance_to(REGION_POINTS[i])/10.5
   if island_distance<1.35:
    var peak=5.0*(1.0-island_distance*island_distance)-.65+noise.get_noise_2d(x*1.5,z*1.5)*.4
    h=maxf(h,peak)
 elif expanded_world:
  for i in range(1,REGION_POINTS.size()):
   var d_island=Vector2(x,z).distance_to(REGION_POINTS[i])/7.4
   if d_island<1.5:h=maxf(h,3.6*(1.0-d_island*d_island)-.55+noise.get_noise_2d(x*2,z*2)*.4)
  for link in REGION_BRIDGES:
   var anchor_dist=Vector2(x,z).distance_to(link[0])
   if anchor_dist<4.0:h=maxf(h,1.2-anchor_dist*.35)
 if vast_world:
  h=Frontier.terrain(self,x,z,h)
  if x< -48 or z>50:h=Rivers.carve(x,z,h)
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
 if ocean.enabled:
  if Vector2(p.x,p.z).distance_to(REGION_POINTS[1])<12:grass=grass.lerp(Color("688e88"),.40)
  elif Vector2(p.x,p.z).distance_to(REGION_POINTS[2])<12:grass=grass.lerp(Color("b4a768"),.36)
 for c in centers:
  if Vector2(p.x-c.x,p.z-c.z).length()<6:
   grass=grass.lerp(Color("b0a280"),.35)
 return Art.ground_color(self,p,grass)

func make_terrain():
 terrain_revision+=1
 if is_instance_valid(earth):
  remove_child(earth)
  earth.queue_free()
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var grid=ceili(192.0/STEP) if vast_world else GRID
 for iz in range(grid):
  for ix in range(grid):
   var x=(ix-grid*.5)*STEP
   var z=(iz-grid*.5)*STEP
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
 var terrain_body=StaticBody3D.new()
 earth.add_child(terrain_body)
 terrain_body.collision_layer=4
 terrain_body.collision_mask=4
 var terrain_shape=CollisionShape3D.new()
 terrain_shape.shape=earth.mesh.create_trimesh_shape()
 terrain_body.add_child(terrain_shape)
 if not is_instance_valid(sea):
  sea=MeshInstance3D.new()
  var wm=PlaneMesh.new()
  wm.size=Vector2(390,390) if vast_world else Vector2(230,230)
  wm.subdivide_width=160 if vast_world else 100
  wm.subdivide_depth=160 if vast_world else 100
  sea.mesh=wm
  var sm=ShaderMaterial.new()
  sm.shader=preload("res://shaders/water.gdshader")
  sea.material_override=sm
  add_child(sea)
  sea.position.y=SEA
  sea.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var extent=192.0 if vast_world else 106.0
 var depth_image=Image.create(128,128,false,Image.FORMAT_RGB8)
 for dz in range(128):
  for dx in range(128):
   var h=height_at(float(dx)/127*extent-extent*.5,float(dz)/127*extent-extent*.5)
   var v=clampf((h+5.0)/20.0,0,1)
   depth_image.set_pixel(dx,dz,Color(v,v,v))
 sea.material_override.set_shader_parameter("height_map",ImageTexture.create_from_image(depth_image))
 sea.material_override.set_shader_parameter("terrain_extent",extent)
 sea.material_override.set_shader_parameter("detail_strength",.25 if quality_mode==0 else .70 if quality_mode==1 else 1.0)

func new_world(seed_value:int,which:int,expanded=false,ocean_mode=false,wide=false,primordial=false):
 if cave.active:cave.leave()
 vast_world=wide
 ash_time=0
 river_saved={}
 cave_saved={}
 expanded_world=expanded or ocean_mode
 hydro_saved={}
 fluid_saved={}
 ocean_dynamics_saved={}
 colony_selected=-1
 set_tour(false)
 unlimited=false
 if is_instance_valid(unlimited_toggle):unlimited_toggle.set_pressed_no_signal(false)
 planted.clear()
 deformation.clear()
 discovery_sites.clear()
 hazards.clear()
 outposts.clear()
 next_hazard=1
 hazard_tick=0.0
 society_tick=0.0
 battle_count=0
 completed_visible=0
 house_sites=[[],[]]
 ruins.clear()
 scars.clear()
 world_centers.clear()
 destroyed_total=0
 sim.start(seed_value,which)
 if vast_world:
  sim.population_limit=Sim.MAX_CITY_POPULATION
  sim.housing_limit=100
 legend.reset(self)
 legacy.reset(self)
 wildlife.reset(self)
 districts.reset(self)
 origins.reset(self)
 ocean.reset(self,ocean_mode)
 sim.spatial_autonomy=not test_mode and not benchmark_mode and not "--capture" in OS.get_cmdline_user_args()
 last_auto_day=-1
 reset_visuals()
 if primordial:origins.begin()
 tick=0
 selected=-1
 following=false
 speed=1
 show_ending=true
 power="Osserva"
 refresh()

func reset_visuals():
 nav_dirty=true
 services_dirty=true
 services.clear()
 claims.clear()
 timber_points.clear()
 for n in [earth,sea,scenery,villages_root,people_root,animals_root,effects_root,cursor,roads_root,farms_root,hover_ring,ambient_root,civic_root,route_root,selected_marker,settlement_root,meadow,landmark_root,ruin_root,service_root,discovery_root,hazard_root,outpost_root,regional_root,ocean_root,physics_root,hydro_root,fluid_root,legend_root,wildlife_root,frontier_root,district_root,origin_root,cave_root,river_root,legacy_root]:
  if is_instance_valid(n):
   remove_child(n)
   n.queue_free()
 earth=null
 sea=null
 meadow=null
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
 if world_centers.size()!=2:
  var c0=land_near(-15,9)
  var c1=land_near(19,-6)
  world_centers=[[c0.x,c0.z],[c1.x,c1.z]]
 centers=[ground(float(world_centers[0][0]),float(world_centers[0][1])),ground(float(world_centers[1][0]),float(world_centers[1][1]))]
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
 ruin_root=Node3D.new()
 service_root=Node3D.new()
 discovery_root=Node3D.new()
 hazard_root=Node3D.new()
 outpost_root=Node3D.new()
 regional_root=Node3D.new()
 add_child(regional_root)
 ocean_root=Node3D.new()
 add_child(ocean_root)
 physics_root=Node3D.new()
 add_child(physics_root)
 debris.reset(self,physics_root)
 hydro_root=Node3D.new()
 add_child(hydro_root)
 hydro.reset(self,hydro_root,hydro_saved)
 fluid_root=Node3D.new()
 add_child(fluid_root)
 fluid_volume.reset(self,fluid_root,fluid_saved)
 ocean_dynamics.reset(self,ocean_dynamics_saved)
 rebuild_regional_bridges()
 hazard_nodes.clear()
 for n in [scenery,villages_root,people_root,animals_root,effects_root,roads_root,farms_root,ambient_root,civic_root,route_root,settlement_root,landmark_root,ruin_root,service_root,discovery_root,hazard_root,outpost_root]:add_child(n)
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
 rebuild_ruins()
 rebuild_meadow()
 for i in range(350):
  var p=ground(rng.randf_range(-45,45),rng.randf_range(-42,42))
  if p.y>SEA+.85 and p.y<8.5 and far_village(p,9) and away_from_route(p,1.65):
   make_tree(p,rng.randf_range(2.3,4.8),i)
 if vast_world:
  for i in range(220):
   var p=ground(rng.randf_range(-91,91),rng.randf_range(-91,91))
   if maxf(absf(p.x),absf(p.z))<53 or p.y<SEA+.7 or p.y>12:continue
   if Frontier.biome(p)==3 and i%3!=0:continue
   make_tree(p,rng.randf_range(2.5,5.4),i)
 for row in planted:
  var place=ground(float(row.x),float(row.z))
  if place.y>SEA+.12:make_tree(place,float(row.h),int(row.i))
 for i in range(100):
  var p=ground(rng.randf_range(-46,46),rng.randf_range(-43,43))
  if p.y>SEA+.2 and far_village(p,4) and away_from_route(p,1.05):
   make_rock(p,rng.randf_range(.45,1.3),i)
 for i in range(110):
  var p=ground(rng.randf_range(-40,40),rng.randf_range(-38,38))
  if p.y>SEA+.4 and p.y<6.8 and far_village(p,2.0) and not scarred(p):
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
 rebuild_navigation()
 rebuild_services()
 rebuild_discoveries()
 rebuild_outposts()
 rebuild_hazards()
 ocean.rebuild_visuals(ocean_root)
 legend_root=Node3D.new()
 add_child(legend_root)
 legend.rebuild_visuals(legend_root)
 wildlife_root=Node3D.new()
 add_child(wildlife_root)
 wildlife.build(wildlife_root)
 frontier_root=Node3D.new()
 add_child(frontier_root)
 if vast_world:Frontier.landmarks(self,frontier_root)
 district_root=Node3D.new()
 add_child(district_root)
 districts.build(district_root)
 origin_root=Node3D.new()
 add_child(origin_root)
 origins.build(origin_root)
 cave_root=Node3D.new()
 add_child(cave_root)
 cave.reset(self,cave_saved)
 if vast_world:cave.build(cave_root)
 river_root=Node3D.new()
 add_child(river_root)
 rivers.reset(self,river_root,river_saved)
 legacy_root=Node3D.new()
 add_child(legacy_root)
 legacy.build(legacy_root)
 rebuild_roads()
 rebuild_services()
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
 var rotation_value=rng.randf()*TAU
 if scarred(p):return
 timber_points.append(p)
 if Art.tree(self,p,h,i):return
 var n=asset(scenery,"tree",i,p,h,rotation_value)
 if n!=null:
  n.set_meta("vegetation",true)
  return
 n=Node3D.new()
 scenery.add_child(n)
 n.set_meta("vegetation",true)
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
 var site=house_sites[i][j]
 Structure.normalize(site)
 var p=ground(float(site.x),float(site.z))
 var n=Node3D.new()
 villages_root.add_child(n)
 n.position=p
 n.rotation.y=atan2(centers[i].x-p.x,centers[i].z-p.z)
 var tint=Color("39766d") if i==0 else Color("a85f3d")
 var wall=Color("bca784") if era<4 else Color("91aaa5")
 var cover=Node3D.new()
 n.add_child(cover)
 n.set_meta("cover",cover)
 var interior=Node3D.new()
 n.add_child(interior)
 n.set_meta("interior",interior)
 block(interior,Color("87725a"),Vector3(0,.06,0),Vector3(2.20,.12,2.20))
 for k in range(4):
  var x=-.69 if k%2==0 else .69
  var z=-.60+float(int(k/2))*.98
  block(interior,Color("5c4e40"),Vector3(x,.18,z),Vector3(.53,.22,.84))
  block(interior,tint,Vector3(x,.32,z),Vector3(.48,.12,.76))
  block(interior,Color("eee0c2"),Vector3(x,.41,z-.28),Vector3(.42,.09,.20))
 block(interior,Color("947759"),Vector3(0,.35,-.65),Vector3(.40,.12,.48))
 sphere(interior,Color("ffc779"),Vector3(0,.47,-.65),Vector3(.17,.18,.17),.7)
 var h=1.55 if era<2 else 1.9 if era<4 else 2.3
 block(cover,wall,Vector3(0,h*.5,-1.01),Vector3(2.15,h,.18))
 for side in [-1,1]:
  block(cover,wall,Vector3(side*1.01,h*.5,0),Vector3(.17,h,2.1))
  block(cover,wall,Vector3(side*.77,h*.5,1.01),Vector3(.58,h,.18))
  block(cover,Color("f5ca7d"),Vector3(side*.76,h*.66,1.12),Vector3(.30,.35,.045),.32)
 block(cover,wall,Vector3(0,h-.16,1.01),Vector3(1.12,.32,.18))
 if era<4:
  if i==0 or era>=2:
   var roof=piece(cover,PrismMesh.new(),tint,Vector3(0,h+.39,0),Vector3(2.44,.85,2.45))
   roof.rotation.y=PI*.5
 else:
  block(cover,tint,Vector3(0,h+.10,0),Vector3(2.42,.23,2.42))
  for k in range(3):block(cover,Color("375e68"),Vector3(-.56+k*.56,h+.25,0),Vector3(.48,.06,.85),.25 if era>=5 else 0.0)
  if era>=5:cone(cover,Color("b7e4db"),Vector3(0,h+.63,0),.25,.82,.03,8,.5)
 for side in [-1,1]:block(cover,Color("80664f"),Vector3(side*.49,.62,1.13),Vector3(.08,1.25,.10))
 Art.house(self,cover,i,era,j,h)
 interior.visible=false
 show_structure(n,site)
 return n


func sync_houses(i:int):
 var v=sim.villages[i]
 while house_sites[i].size()>int(v.houses):
  house_sites[i].pop_back()
 while house_sites[i].size()<int(v.houses):
  var site={}
  for old in ruins:
   if int(old.clan)!=i or sim.day<int(old.until):continue
   var q=ground(float(old.x),float(old.z))
   if q.y>SEA+.7 and not occupied_site(i,q):
    site={"x":q.x,"z":q.z}
    ruins.erase(old)
    rebuild_ruins()
    break
  if site.is_empty():
   for j in range(360 if vast_world else 180):
    var q=house_location(i,j)
    if q.y>SEA+.7 and not occupied_site(i,q) and not blocked_site(q):
     site={"x":q.x,"z":q.z}
     break
  if site.is_empty():
   v.houses=house_sites[i].size()
   break
  house_sites[i].append(site)
 for old in houses[i]:
  if is_instance_valid(old.node):
   old.node.hide()
   old.node.queue_free()
 houses[i].clear()
 for j in range(house_sites[i].size()):
  houses[i].append({"node":make_house(i,j,v.era),"era":v.era})
 nav_dirty=true
 rebuild_roads()

func original_creature(parent:Node3D,a:Dictionary)->Dictionary:
 var skin=Color("399c98").lerp(Color("93d6b6"),float(a.genes[2])) if a.clan==0 else Color("a95c3f").lerp(Color("e8be78"),float(a.genes[2]))
 var cloth=(Color("244b59") if a.clan==0 else Color("683e4c")).lerp(Color("bba16e"),float(a.genes[1])*.55)
 var era=int(sim.villages[a.clan].era)
 if era>=4:cloth=cloth.lerp(Color("88a9be"),.45)
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
 var brows=[]
 for side in [-1,1]:
  var ear=sphere(body,skin.darkened(.08),Vector3(side*.39,1.42,.0),Vector3(.24,.38,.18))
  ear.rotation.z=side*-.56
  ear.scale.y*=lerpf(.75,1.30,float(a.genes[0]))
  sphere(body,skin.lightened(.25),Vector3(side*.39,1.43,.083),Vector3(.11,.22,.05)).rotation.z=side*-.56
  var eye=Node3D.new()
  body.add_child(eye)
  eye.position=Vector3(side*.18,1.30,.29)
  sphere(eye,Color("f2e6c9"),Vector3.ZERO,Vector3(.25,.28,.15))
  sphere(eye,Color("527876").lerp(Color("ab7b3d"),float(a.genes[2])),Vector3(0,0,.07),Vector3(.16,.19,.07))
  sphere(eye,Color("263b3a"),Vector3(0,0,.107),Vector3(.107,.139,.045))
  sphere(eye,Color("fff9e2"),Vector3(-.035,.05,.13),Vector3(.047,.047,.024))
  eyes.append(eye)
  var brow=sphere(body,skin.darkened(.26),Vector3(side*.18,1.49,.28),Vector3(.19,.048,.045))
  brow.rotation.z=side*lerpf(-.10,.18,float(a.genes[0]))
  brows.append(brow)
  var arm=Node3D.new()
  body.add_child(arm)
  arm.position=Vector3(side*.34,.98,.0)
  arms.append(arm)
  var leg=Node3D.new()
  body.add_child(leg)
  leg.position=Vector3(side*.18,.43,0)
  legs.append(leg)
 var mouth=sphere(body,skin.darkened(.26),Vector3(0,1.13,.345),Vector3(.12,.065,.04))
 for j in range(3):
  sphere(body,accent,Vector3((j-1)*.10,1.55,.20),Vector3(.06,.08,.035),.5)
 var crest=cone(body,skin.lightened(.18),Vector3(0,1.68,-.08),.11,.18+float(a.genes[3])*.22,.015,7)
 crest.rotation.x=-.35
 if a.genes[1]>.55:
  for side in [-1,1]:sphere(body,accent,Vector3(side*.27,1.16,.28),Vector3(.09,.045,.027))
 if a.genes[0]>.65:sphere(body,accent,Vector3(0,1.70,-.05),Vector3(.19,.12,.17),.2)
 if a.genes[3]>.65:
  for side in [-1,1]:sphere(body,cloth,Vector3(side*.34,.88,.03),Vector3(.22,.22,.28))
 if era>=3:block(body,accent,Vector3(0,.92,.29),Vector3(.18,.11,.055),.15 if era>=5 else 0.0)
 var skeletal=CreatureRig.build(self,body,skin,cloth)
 torso.hide()
 torso.queue_free()
 head.hide()
 head.queue_free()
 for child in body.get_children():
  if child==torso or child==head or child==skeletal.skeleton or arms.has(child) or legs.has(child):continue
  if not child is Node3D:continue
  var original:Vector3=child.position
  var face_part=original.y>=1.07
  var target:Node3D=skeletal.head_anchor if face_part else skeletal.chest_anchor
  child.reparent(target,false)
  child.position=original-(Vector3(0,1.24,.025) if face_part else Vector3(0,.97,0))
 return {"body":body,"arms":arms,"legs":legs,"eyes":eyes,"brows":brows,"mouth":mouth,"skeletal":skeletal}

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
 actors[a.id]["brows"]=rig.get("brows",[])
 actors[a.id]["mouth"]=rig.get("mouth")
 actors[a.id]["skeletal"]=rig.get("skeletal",{})
 Art.portrait(self,actors[a.id],a)
 LivingArt.morphology(self,actors[a.id],a)
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
 var marker=Label3D.new()
 parent.add_child(marker)
 marker.position=Vector3(0,1.68,0)
 marker.font_size=34
 marker.outline_size=7
 marker.pixel_size=.006
 marker.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 marker.hide()
 actors[a.id]["action_marker"]=marker
 var prop=Node3D.new()
 rig.body.add_child(prop)
 prop.position=Vector3(.0,.82,.38)
 actors[a.id]["action_prop"]=prop

func apply_changes():
 for e in sim.changes:
  match e.kind:
   "birth":
    var a=sim.find(int(e.id))
    if not a.is_empty():
     create_actor(a)
     if sim.spatial_autonomy:
      if not a.parents.is_empty() and actors.has(int(a.parents[0])):actors[a.id].node.position=actors[int(a.parents[0])].node.position+Vector3(.5,0,0)
      life_bubble(actors[a.id].node.position,"NUOVA VITA",Color("f4d1a0"))
     if not test_mode and legend!=null:legend.born(a,actors[a.id].node.position)
    services_dirty=true
   "emigration":
    claims.erase(int(e.id))
    if actors.has(e.id):
     actors[e.id].node.queue_free()
     actors.erase(e.id)
     activity_labels.erase(e.id)
    services_dirty=true
    if selected==e.id:selected=-1
   "death":
    if ocean.enabled:
     ocean.finance.settle_depositor(int(e.get("clan",0)),int(e.id))
     ocean.change(int(e.get("clan",0)),"cash",float(e.get("cash",0)))
    claims.erase(int(e.id))
    if actors.has(e.id):
     var n=actors[e.id].node
     if not test_mode:legend.death(int(e.id),n.position)
     spark(n.position+Vector3(0,.6,0),Color("b8dad0"),.55)
     if sim.spatial_autonomy:life_bubble(n.position,"ADDIO",Color("c0d2e3"))
     n.queue_free()
     actors.erase(e.id)
     activity_labels.erase(e.id)
    services_dirty=true
    if selected==e.id:selected=-1
   "house","era":
    if e.kind=="era" and not test_mode:
     legend.era(int(e.clan))
     legacy.preserve("Era",int(e.clan),-1,sim.CLANs_name(int(e.clan))+" · "+Sim.ERAS[sim.villages[int(e.clan)].era],centers[int(e.clan)])
    sync_houses(int(e.clan))
    nav_dirty=true
    rebuild_farms()
    rebuild_settlement_details()
    rebuild_landmarks()
   "trade":spawn_caravan(int(e.id))
   "trade_arrived":remove_caravan(int(e.id))
   "project":rebuild_civic()
   "culture":
    if not test_mode:
     var q:Vector3=centers[int(e.clan)]
     if str(e.event_type)=="festival":
      life_bubble(q,"FESTA DELLA MEMORIA",Color("f0d291"))
      for j in range(5):spark(q+Vector3(cos(j*TAU/5)*2,.7,sin(j*TAU/5)*2),Color("e8c779"),.7)
     elif str(e.event_type)=="vote":life_bubble(q,"NUOVO CONSIGLIO",Color("afdfcf"))
   "migration":
    claims.erase(int(e.id))
    var a=sim.find(int(e.id))
    if not a.is_empty() and actors.has(a.id):
     a.task=""
     a.home_key=""
     a.station_id=""
     a.delivery=false
     a.cargo=""
     actors[a.id]["route"]=[]
     actors[a.id]["planned_task"]=""
 sim.changes.clear()

func step_day():
 if origins.active:
  sim.day+=1
  sim.season=["Primavera","Estate","Autunno","Inverno"][int(sim.day/30)%4]
  origins.daily()
  if sim.day%15==0 and autosave_enabled and not test_mode:save_path("user://genesis47_auto.json",false)
  refresh()
  return
 var old_tech=sim.discoveries.size()
 var previous_projects=sim.projects_completed
 var previous_crises=sim.crises_seen
 var treasury_before=[float(sim.villages[0].culture.treasury),float(sim.villages[1].culture.treasury)]
 sim.daily()
 if ocean.enabled:
  for clan in range(2):ocean.change(clan,"cash",maxf(0,float(treasury_before[clan])-float(sim.villages[clan].culture.treasury)))
 ocean.daily()
 apply_changes()
 if not test_mode:
  legend.daily()
  legacy.daily()
  wildlife.daily()
  districts.sync()
  if sim.day%7==0:rebuild_roads()
 if sim.day%7==0:
  repair_structures()
  rebuild_farms()
  services_dirty=true
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
 if cave.active:
  cave.tick(delta)
  return
 if is_instance_valid(title_intro) and title_intro.visible:
  intro_time+=delta
  focus=centers[0].lerp(centers[1],.38+.16*sin(intro_time*.09))
  distance=42+sin(intro_time*.13)*4
  azimuth=-.65+intro_time*.035
  pitch=.52
  update_camera()
 visual_time+=delta
 living_score.update(delta)
 if impact_shake>0:
  impact_shake=maxf(0,impact_shake-delta*1.4)
  camera.h_offset=sin(visual_time*46)*impact_shake*.18
  camera.v_offset=cos(visual_time*53)*impact_shake*.12
  if is_instance_valid(impact_flash):impact_flash.color=Color(1,.72,.36,impact_shake*.12)
 else:
  camera.h_offset=0
  camera.v_offset=0
  if is_instance_valid(impact_flash):impact_flash.color=Color(1,1,1,0)
 fps_clock+=delta
 if fps_clock>=1.0:
  fps_clock=0.0
  if is_instance_valid(fps_label):fps_label.text=str(Engine.get_frames_per_second())+" FPS"
 if tour:update_tour(delta)
 if toast_time>0:
  toast_time-=delta
  if toast_time<=0 and is_instance_valid(toast_panel):toast_panel.hide()
 var focused=get_viewport().gui_get_focus_owner()
 var keyboard_ok=not (focused is LineEdit or focused is TextEdit) and not welcome_open and not (is_instance_valid(title_intro) and title_intro.visible)
 var mov=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if keyboard_ok and mov.length()>0:
  set_tour(false)
  following=false
  var right=Vector3(cos(azimuth),0,-sin(azimuth))
  var back=Vector3(sin(azimuth),0,cos(azimuth))
  focus+=(right*mov.x+back*mov.y)*delta*distance*.40
  focus.x=clampf(focus.x,-94 if vast_world else -50,94 if vast_world else 50)
  focus.z=clampf(focus.z,-94 if vast_world else -50,94 if vast_world else 50)
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
  if nav_dirty:
   rebuild_navigation()
   services_dirty=true
  if services_dirty:rebuild_services()
  update_house_views()
  for a in sim.people.duplicate():
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
   update_action_visual(a,r,moving)
   var rig_elapsed=float(r.get("rig_elapsed",0))+delta
   var detailed=distance<35 and quality_mode>0 and flat_dist(n.position,focus)<28
   if detailed or rig_elapsed>=.10:
    CreatureRig.drive(r,a,moving,detailed,rig_elapsed)
    if detailed:Art.portrait(self,r,a)
    LivingArt.animate_morph(r,a,moving)
    rig_elapsed=0.0
   r["rig_elapsed"]=rig_elapsed
   if is_instance_valid(r.get("signet")):
    r.signet.visible=distance<20 and not photo_mode and (a.favorite or a.id==selected or a.sick>0)
    r.signet.text="★" if a.favorite else "+" if a.sick>0 else "◆"
  if not sim.changes.is_empty():apply_changes()
  society_tick+=delta*minf(speed,20.0)
  if society_tick>=1.0:
   society_tick=0.0
   spatial_society()
  update_worksites()
  ocean.life.tick(delta*minf(speed,20.0))
  wildlife.tick(delta*minf(speed,20.0))
  ocean.industry.animate(delta*minf(speed,4.0))
  hydro.tick(delta*minf(speed,12.0))
  fluid_volume.tick(delta*minf(speed,4.0))
  ocean_dynamics.tick(delta*minf(speed,4.0))
  if vast_world:rivers.tick(delta*minf(speed,4.0))
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
   refresh()
   update_service_labels()
  var phase=fmod(float(sim.day)+tick/1.7,16.0)/16.0
  var daylight=clampf(.66+.43*sin(phase*TAU+.8),.20,1)
  sun.light_energy=.14+daylight*.70
  sun.light_color=Color("a4baff").lerp(Color("ffe7bd"),daylight)
  sun.rotation_degrees=Vector3(-22-daylight*38,-37+sin(phase*TAU)*24,0)
  env.ambient_light_color=Color("a4bdd8").lerp(Color("e2e7d3"),daylight)
  env.ambient_light_energy=.12+daylight*.31
  for lamp in village_lights:
   if is_instance_valid(lamp):lamp.light_energy=(1.0-daylight)*.85 if quality_mode>0 else 0.0
  sky_material.sky_top_color=Color("172b51").lerp(Color("4d86b4"),daylight)
  sky_material.sky_horizon_color=Color("495478").lerp(Color("cfdfd4"),daylight)
  env.fog_light_color=Color("374f68").lerp(Color("afc8cf"),daylight)
 if ash_time>0:
  ash_time=maxf(0,ash_time-delta*minf(speed,2.0))
  var haze=clampf(ash_time/8,0,1)
  env.fog_density=.0013+.018*haze
  env.fog_light_color=Color("74665d")
  sun.light_energy*=1-.55*haze
 else:env.fog_density=.0013
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
 ocean.animate(float(sim.day)+tick/1.7,visual_time)
 debris.update(delta,speed<=0)
 update_clouds(delta)
 for rotor in civic_spinners:
  if is_instance_valid(rotor):rotor.rotation.y+=delta*.38
 if is_instance_valid(hover_ring):
  hover_ring.visible=false
  if power!="Osserva" and not photo_mode and (get_viewport().gui_get_hovered_control()==null or get_viewport().gui_get_hovered_control()==hud):
   var hp=ground_at(get_viewport().get_mouse_position())
   if hp.y>SEA-.5:
    hover_ring.position=hp+Vector3.UP*.12
    var radius=float({"Incendio":3.0,"Terremoto":8.0,"Tornado":4.0,"Epidemia":6.0,"Meteorite":7.0,"Fulmine":2.4,"Tsunami":11.0,"Vulcano":9.0,"Montagna":5.0,"Lago":6.0}.get(power,6.0))
    hover_ring.scale=Vector3(radius/6.0,1,radius/6.0)
    hover_ring.visible=true
 update_effects(delta)
 if speed>0:update_hazards(delta*minf(speed,12.0))

func _unhandled_input(event:InputEvent):
 if is_instance_valid(title_intro) and title_intro.visible:return
 if cave.active:
  if event is InputEventKey and event.pressed and event.keycode in [KEY_C,KEY_ESCAPE]:cave.leave()
  return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_F10:toggle_photo()
  if event.keycode==KEY_F1:show_help()
  if event.keycode==KEY_F2:start_onboarding()
  if event.keycode==KEY_TAB:toggle_compact()
  if event.keycode==KEY_L:show_legend()
  if event.keycode==KEY_C and vast_world:
   if not cave.enter():
    following=false
    focus=cave.entrance()
    distance=12
    pitch=.7
    update_camera()
    hint.text="Premi C di nuovo per entrare nella grotta."
  if event.keycode==KEY_P:left_panel.visible=not left_panel.visible;refresh()
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
  focus.x=clampf(focus.x,-94 if vast_world else -50,94 if vast_world else 50)
  focus.z=clampf(focus.z,-94 if vast_world else -50,94 if vast_world else 50)
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
   distance=minf(220 if vast_world else 125,distance*1.16)
   update_camera()
  elif event.button_index==MOUSE_BUTTON_LEFT:
   set_tour(false)
   if power=="Osserva":
    select_at(event.position)
    if selected>=0 and onboarding_step==1 and onboarding.visible:advance_onboarding()
    if event.double_click and actors.has(selected):follow_person(selected)
   else:
    var p=ground_at(event.position)
    if p.y>SEA-.5 and absf(p.x)<(94 if vast_world else 51) and absf(p.z)<(94 if vast_world else 51):divine(p)

func ground_at(mouse:Vector2)->Vector3:
 var origin=camera.project_ray_origin(mouse)
 var dir=camera.project_ray_normal(mouse)
 var previous=origin
 for i in range(1000):
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
 colony_selected=-1
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
 for id in ocean.life.actors:
  var p:Vector3=ocean.life.actors[id].node.position+Vector3(0,.55,0)
  if camera.is_position_behind(p):continue
  var dist=camera.unproject_position(p).distance_to(mouse)
  if dist<best:
   best=dist
   selected=-1
   colony_selected=int(id)
 if selected>=0:
  if not test_mode:legend.meet(selected,false)
  if player_hud:right_panel.show();inspector_tabs.current_tab=0
 if colony_selected>=0:
  var a=ocean.life.find(colony_selected)
  if not a.is_empty():
   open_dialog(str(a.name),colony_citizen_report(a))
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

func meteor(p:Vector3,destructive=false):
 var n=Node3D.new()
 effects_root.add_child(n)
 n.position=p+Vector3(-12,24,-6)
 sphere(n,Color("f8a052"),Vector3.ZERO,Vector3.ONE*1.5,1.4)
 sphere(n,Color("ffe4a2"),Vector3(.1,.05,.03),Vector3.ONE*.95,1.9)
 for i in range(8):
  sphere(n,Color("ef7c42").lerp(Color("ffd48b"),float(i)/8),Vector3(-.3*i,.62*i,-.15*i),Vector3.ONE*(1.05-float(i)*.095),1.1)
 effects.append({"node":n,"life":1.1,"max":1.1,"kind":"meteor","dest":p,"from":n.position,"destructive":destructive})

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
    if e.get("destructive",false):
     e.destructive=false
     disaster(e.dest,"Meteorite",7.0,125.0,-3.0,5.0)
  elif e.kind=="bubble":
   e.node.position.y+=delta*.23
   e.node.modulate.a=1.0-frac
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
 for collection in [scenery,villages_root,people_root,animals_root,civic_root,farms_root,ruin_root]:
  for n in collection.get_children():
   if n is Node3D:n.position.y=height_at(n.position.x,n.position.z)
 for i in range(centers.size()):centers[i]=ground(centers[i].x,centers[i].z)
 rebuild_roads()
 rebuild_trade_route()
 rebuild_regional_bridges()
 rebuild_settlement_details()
 rebuild_landmarks()
 rebuild_meadow()

func divine(p:Vector3):
 if vast_world and maxf(absf(p.x),absf(p.z))>51 and power=="Tsunami":
  hint.text="Lo tsunami agisce nel bacino oceanico centrale."
  return
 if origins.active:
  hint.text="Durante le Origini osserva l’evoluzione delle forme primitive."
  return
 if power=="Osserva":return
 var cost=18.0 if power in ["Meteorite","Tsunami","Vulcano","Resurrezione","Montagna","Lago","Incendio","Terremoto","Tornado","Epidemia"] else 9.0
 if power in ["Vita","Nuova specie","Resurrezione"] and sim.people.size()>=sim.population_limit:
  hint.text="Limite della popolazione raggiunto."
  return
 if power=="Foresta" and scarred(p):
  hint.text="Terreno danneggiato: attendi la rigenerazione."
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
   services_dirty=true
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
   if not test_mode:warn_near(p,8.0)
   meteor(p,true)
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
   disaster(p,"Fulmine",2.4,70.0,0.0,0.0)
  "Tsunami":
   var heading=Vector3(-p.x,0,-p.z).normalized()
   if heading.length_squared()<.01:heading=Vector3.FORWARD
   ocean_dynamics.disturb(p,.65)
   var emitted=fluid_volume.emit(p,400,heading*4+Vector3.UP*2)
   if emitted<400:hydro.inject(p,(400-emitted)*FluidVolume.PARTICLE_MASS)
   wave(p)
   color=Color("7fc9dd")
   start_hazard("flood",p,6.0)
  "Vulcano":
   if not test_mode:ash_time=24.0
   impact_cloud(p)
   color=Color("e67f43")
   disaster(p,"Vulcano",9.0,110.0,5.0,7.0)
   start_hazard("fire",p,10.0)
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
  "Montagna":disaster(p,"Montagna",5.0,35.0,3.8,6.0)
  "Lago":disaster(p,"Lago",6.0,80.0,-4.8,6.0)
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
  "Incendio":
   color=Color("ef8542")
   start_hazard("fire",p,12.0)
  "Terremoto":
   color=Color("c4a17d")
   disaster(p,"Terremoto",8.0,70.0,-.45,7.0)
  "Tornado":
   color=Color("c1d3d2")
   start_hazard("tornado",p,10.0)
  "Epidemia":
   color=Color("a3b76d")
   for a in near:
    a.sick=maxi(a.sick,9)
    a.stress=minf(100,a.stress+20)
   life_bubble(p,"CONTAGIO",color)
 for a in near:
  if sim.find(int(a.id)).is_empty():continue
  if power in ["Guarigione","Provviste","Pace","Pioggia"]:sim.adjust_trust(a,5)
  elif power in ["Meteorite","Fulmine","Tsunami","Vulcano","Carestia"]:sim.adjust_trust(a,-12)
 if not test_mode:
  legend.miracle(power,clan,near,p)
  legacy.preserve("Miracolo",clan,-1,power+" · "+str(near.size())+" testimoni",p)
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
 s.bg_color=Color(.075,.105,.12,opacity)
 s.border_color=Color("59756d")
 s.set_border_width_all(1)
 s.set_corner_radius_all(12)
 s.shadow_color=Color(0,0,0,.22)
 s.shadow_size=5
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
 theme.default_font_size=15
 theme.set_color("font_color","Button",Color("eee9d7"))
 for state in ["normal","hover","pressed","focus","disabled"]:
  var s=StyleBoxFlat.new()
  s.bg_color=Color("253b40") if state=="normal" else Color("47645b") if state!="disabled" else Color("1d292d")
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
 title=text_label(row,"GENESIS 47   /   EREDITÀ VIVENTE",21)
 title.modulate=Color("e8ce9e")
 var sp=Control.new()
 row.add_child(sp)
 sp.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button(row,"Poteri [P]",func():left_panel.visible=not left_panel.visible;refresh())
 button(row,"Vite",func():right_panel.visible=not right_panel.visible;inspector_tabs.current_tab=0)
 button(row,"Cronaca",show_legend)
 button(row,"Guida",show_help)
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
 var left=panel(hud,Rect2(14,104,196,430),.94)
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
 scroll.custom_minimum_size=Vector2(155,216)
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 lv.add_child(scroll)
 power_grid=VBoxContainer.new()
 scroll.add_child(power_grid)
 power_grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 populate_powers(0)
 button(lv,"Osserva il mondo",func():power="Osserva";selected=-1;following=false;refresh();populate_powers(power_category.selected))
 map_panel=panel(hud,Rect2(14,550,196,174),.86)
 var mv=VBoxContainer.new()
 map_panel.add_child(mv)
 map_region=text_label(mv,"ATLANTE",12)
 map_region.modulate=Color("e8ce9e")
 map_view=preload("res://scripts/minimap.gd").new()
 map_view.world=self
 map_view.custom_minimum_size=Vector2(155,135)
 mv.add_child(map_view)
 unlimited_toggle=CheckButton.new()
 unlimited_toggle.text="Energia infinita"
 unlimited_toggle.toggled.connect(func(on):unlimited=on)
 lv.add_child(unlimited_toggle)
 var right=panel(hud,Rect2(1108,104,318,620),.95)
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
 citizen_portrait=preload("res://scripts/portrait_widget.gd").new()
 citizen_portrait.custom_minimum_size=Vector2(0,104)
 inspect.add_child(citizen_portrait)
 citizen_portrait.hide()
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
 details=rich(inspect,142)
 details.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var line=HBoxContainer.new()
 inspect.add_child(line)
 button(line,"Segui",func():follow_person(selected))
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
 button(archive,"Etichette dei luoghi",func():show_world_labels=not show_world_labels;update_service_labels())
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
 button(chat,"Segnali delle creature",show_signals)
 text_label(chat,"Seleziona un abitante prima di parlargli.",12).autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var culture_tab=VBoxContainer.new()
 culture_tab.name="Cultura"
 inspector_tabs.add_child(culture_tab)
 text_label(culture_tab,"SOCIETÀ E TERRITORI",15)
 culture_view=rich(culture_tab,180)
 culture_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
 button(culture_tab,"Isola delle origini",func():observe_region(0))
 button(culture_tab,"Isola del vento",func():observe_region(1))
 button(culture_tab,"Isola dell’alba",func():observe_region(2))
 button(culture_tab,"Atlante delle regioni",show_regions)
 var market_tab=VBoxContainer.new()
 market_tab.name="Mercato"
 inspector_tabs.add_child(market_tab)
 text_label(market_tab,"PORTI E COMMERCI",15)
 market_view=rich(market_tab,180)
 market_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
 button(market_tab,"Atlante colonie",show_regions)
 button(market_tab,"Spedizione Auralis",func():request_expedition(0))
 button(market_tab,"Spedizione Nerith",func():request_expedition(1))
 var story_tab=VBoxContainer.new()
 story_tab.name="Leggenda"
 inspector_tabs.add_child(story_tab)
 text_label(story_tab,"STORIA DEL TUO MONDO",16)
 legend_view=rich(story_tab,330)
 legend_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
 button(story_tab,"Segui una storia",follow_story)
 button(story_tab,"Luoghi della memoria",show_story_locations)
 button(story_tab,"Genealogia",func():
  if selected>=0:open_dialog("ALBERO DELLA VITA",legend.genealogy(selected))
  else:open_dialog("ALBERO DELLA VITA","Seleziona prima un abitante."))
 button(story_tab,"Esplora i biomi",show_biomes)
 inspector_tabs.tab_changed.connect(func(_tab):refresh())
 var bottom=panel(hud,Rect2(14,746,1412,140),.87)
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
 journey_label=text_label(bv,"",17)
 journey_label.modulate=Color("f0d5a2")
 objective=text_label(bv,"",13)
 chronicle=rich(bv,32)
 life_overlay=text_label(bv,"",12)
 life_overlay.modulate=Color("b9dbc8")
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
 impact_flash=ColorRect.new()
 hud.add_child(impact_flash)
 impact_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 impact_flash.color=Color(1,1,1,0)
 impact_flash.mouse_filter=Control.MOUSE_FILTER_IGNORE
 left_panel.hide()
 right_panel.hide()
 map_panel.show()

func toggle_photo():
 photo_mode=not photo_mode
 hud.visible=not photo_mode

func refresh():
 if top==null or sim.villages.size()!=2:return
 var global_population=sim.people.size()
 for colony in ocean.colonies:global_population+=int(colony.population)
 for voyage in ocean.voyages:
  if voyage.kind=="settle":global_population+=voyage.crew.size()
 if is_instance_valid(map_panel):map_panel.visible=player_hud
 if is_instance_valid(map_region):map_region.text=Art.BIOMES[Art.biome(self,ground(focus.x,focus.z))]
 if is_instance_valid(journey_label):journey_label.text=legend.goal_text()
 if is_instance_valid(legend_view) and inspector_tabs.current_tab==5:legend_view.text=legend.report()+"\n\n"+wildlife.report()+"\n\n"+legacy.report()
 top.text="GIORNO %03d  ·  %d ABITANTI  ·  ENERGIA %d%%  ·  PACE %d%%"%[sim.day,global_population,int(sim.energy),int(sim.peace)]
 if life_overlay!=null:
  life_overlay.text="Attività concluse: %d  ·  Luoghi scoperti: %d  ·  TAB: osservazione libera"%[completed_visible,discovery_sites.filter(func(q):return q.found).size()]
  if ocean.enabled:life_overlay.text+="  ·  Colonie %d · Navi %d"%[ocean.colonies.size(),ocean.voyages.size()]
 top.text+="    ·    "+sim.season+" / "+sim.weather_name
 power_label.text=power
 if map_view!=null:map_view.queue_redraw()
 update_time_buttons()
 if signals_button!=null:
  var pending=sim.signals.filter(func(q):return not q.answered and not sim.find(int(q.id)).is_empty()).size()
  signals_button.text="Segnali "+str(pending) if pending>0 else "Segnali"
 var a=sim.find(selected)
 if is_instance_valid(citizen_portrait):citizen_portrait.set_person(a)
 if selected_status!=null:selected_status.text="Osservazione del mondo" if a.is_empty() else LivingArt.variant(a)+" · "+str(a.get("activity","Decide"))
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
 if is_instance_valid(culture_view) and inspector_tabs.current_tab==3:culture_view.text=sim.culture_report()
 if is_instance_valid(market_view) and inspector_tabs.current_tab==4:market_view.text=ocean.report()
 if event_feed!=null:event_feed.text="\n".join(sim.events.slice(0,18))
 if social_summary!=null:social_summary.text="Vita sociale: %d azioni · %d aiuti · %d incontri"%[sim.social_actions,sim.aid_actions,sim.meet_actions]
 if route_status!=null:route_status.text="Carovane: %d in viaggio · %d arrivate\nEdifici distrutti: %d · macerie: %d"%[sim.shipments.size(),sim.trades,destroyed_total,ruins.size()]
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
  details.text="UMORE: "+str(a.emotion)+" · "+str(a.routine)+"\n"+(str(a.special_memory)+"\n" if int(a.special_until)>sim.day else "")+details.text
  details.text+="\nRisparmi: "+str(int(a.coins))+" · Utensile: "+str(int(a.tool))+"%\n"+ "Carattere: "+str(a.social_style)
  details.text+="\nDimora: "+("assegnata" if not str(a.get("home_key","")).is_empty() else "senza casa")+" · Carico: "+(str(a.get("cargo","")) if not str(a.get("cargo","")).is_empty() else "—")
  details.text+="\n\nPERSONALITÀ\n"+sim.personality(a)+"\nAmicizia: "+family_names([a.friend])
  details.text+="\nSocialità: "+str(int(a.get("social_need",0)))+"% · Esperienza: "+str(int(a.get("skill",0)))+"%"
  if int(a.get("social_target",-1))>=0:details.text+="\nIncontro: "+family_names([a.social_target])
 objective.text=["ETERNITÀ  —  Nessun limite di durata.","ALLEANZA  —  Giorno 90 · pace 70% · entrambi i popoli nell'era Regni.","OLTRE IL CIELO  —  Giorno 100 · era Contatto.","ULTIMA SCINTILLA  —  Giorno 120 · almeno 24 sopravvissuti."][sim.mode]
 if not a.is_empty() and int(a.get("intention_until",0))>sim.day:details.text+="\n\nPRIORITÀ PERSONALE: "+str(a.get("intention",""))+" · fino al giorno "+str(a.intention_until)
 if origins.active:
  journey_label.text=origins.report()
  objective.text="Osserva le generazioni primitive: la vita intelligente deve emergere."
 elif sim.mode==0:
  if legend.journey<Legend.GOALS.size():objective.text=Legend.HELP[legend.journey]
  if sim.people.is_empty():objective.text="ETERNITÀ — Mondo disabitato. Usa Vita per ricominciare."
  elif sim.legacy_cycles>0:objective.text+="  ·  Cicli del futuro: "+str(sim.legacy_cycles)
 if sim.mode==0 and not sim.active_crisis.is_empty():
  objective.text=Sim.CRISIS_NAMES[int(sim.active_crisis.kind)]+" · "+Sim.CLANS[int(sim.active_crisis.clan)]+" · fino al giorno "+str(sim.active_crisis.until)
 if sim.ended!="":objective.text=sim.ended
 chronicle.text=str(legend.entries[0].caption) if not legend.entries.is_empty() else "\n".join(sim.events.slice(0,1))
 if inspector_tabs!=null:
  var unread=sim.signals.filter(func(q):return not q.answered and not sim.find(int(q.id)).is_empty()).size()
  inspector_tabs.set_tab_title(1,"Mondo"+(" · "+str(unread) if unread>0 else ""))

func open_welcome():
 if welcome_open:return
 welcome_open=true
 speed=0
 var dlg=ConfirmationDialog.new()
 hud.add_child(dlg)
 dlg.title="GENESIS 47  /  La vita ti aspetta"
 dlg.ok_button_text="Crea il mondo"
 dlg.cancel_button_text="Continua"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 text_label(box,"Un mondo che vive, anche quando non intervieni.",18)
 text_label(box,"Eternità: nessun finale obbligatorio, nemmeno dopo l’estinzione.",14)
 text_label(box,"Oppure scegli una sfida narrativa facoltativa.",14)
 var option=OptionButton.new()
 for s in ["Eternità — mondo infinito","L'alleanza — pace","Oltre il cielo — contatto","L'ultima scintilla — sopravvivenza"]:option.add_item(s)
 box.add_child(option)
 var seed_input=LineEdit.new()
 seed_input.text=str(rng.randi_range(1,999999))
 box.add_child(seed_input)
 text_label(box,"Seme del mondo · cambia il numero per creare una nuova mappa",13)
 var world_choice=OptionButton.new()
 for label in ["Isola classica","Arcipelago con ponti","Continenti separati · oceano e colonie","Grande frontiera · quattro regioni aggiuntive"]:world_choice.add_item(label)
 world_choice.select(3)
 box.add_child(world_choice)
 var primordial=CheckButton.new()
 primordial.text="Origini · inizia dalle forme primitive"
 box.add_child(primordial)
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
  new_world(maxi(1,abs(int(seed_input.text))),option.selected,world_choice.selected>0,world_choice.selected>=2,world_choice.selected==3,primordial.button_pressed and option.selected==0)
  dlg.queue_free()
  left_panel.hide()
  right_panel.hide()
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

func save_game(show_hint:bool):
 save_path(SAVE_PREFIX+str(slot)+".json",show_hint)

func save_path(path:String,show_hint:bool)->bool:
 var d=sim.export_state()
 d["expanded_world"]=expanded_world
 d["vast_world"]=vast_world
 d["districts"]=districts.export_state()
 d["origins"]=origins.export_state()
 d["legacy"]=legacy.export_state()
 d["ash_time"]=ash_time
 d["cave"]=cave.export_state()
 d["rivers"]=rivers.export_state()
 d["ocean"]=ocean.export_state()
 d["hydrology"]=hydro.export_state()
 d["fluid_volume"]=fluid_volume.export_state()
 d["ocean_dynamics"]=ocean_dynamics.export_state()
 d["legend"]=legend.export_state()
 d["wildlife"]=wildlife.export_state()
 d["deformation"]=deformation
 d["planted"]=planted
 d["house_sites"]=house_sites
 d["ruins"]=ruins
 d["scars"]=scars
 d["world_centers"]=world_centers
 d["destroyed_total"]=destroyed_total
 d["discovery_sites"]=discovery_sites
 d["completed_visible"]=completed_visible
 d["hazards"]=hazards
 d["next_hazard"]=next_hazard
 d["battle_count"]=battle_count
 d["outposts"]=outposts
 d["pending_meteors"]=[]
 for e in effects:
  if e.kind=="meteor" and e.get("destructive",false):d.pending_meteors.append([e.dest.x,e.dest.z])
 d["positions"]={}
 for id in actors:
  var p:Vector3=actors[id].get("door_position",actors[id].node.position)
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
 set_tour(false)
 if cave.active:cave.leave()
 sim=candidate
 ash_time=clampf(float(data.get("ash_time",0)),0,24)
 river_saved=data.get("rivers",{})
 cave_saved=data.get("cave",{})
 vast_world=bool(data.get("vast_world",false))
 districts.reset(self,data.get("districts",{}))
 origins.reset(self,data.get("origins",{}))
 legend.reset(self,data.get("legend",{}))
 legacy.reset(self,data.get("legacy",{}))
 wildlife.reset(self,data.get("wildlife",{}))
 ocean.restore(self,data.get("ocean",{}))
 hydro_saved=data.get("hydrology",{})
 fluid_saved=data.get("fluid_volume",{})
 ocean_dynamics_saved=data.get("ocean_dynamics",{})
 colony_selected=-1
 var advanced=0
 if absent_progress and not test_mode and not origins.active:
  advanced=sim.advance_absence(maxf(0,Time.get_unix_time_from_system()-float(data.get("saved_at",Time.get_unix_time_from_system()))))
 sim.spatial_autonomy=not test_mode and not benchmark_mode
 if advanced>0:
  for person in sim.people:person.task="";person.task_stage="Decide"
 expanded_world=bool(data.get("expanded_world",false)) or ocean.enabled
 deformation=data.get("deformation",[])
 planted=data.get("planted",[])
 house_sites=data.get("house_sites",[[],[]])
 if not house_sites is Array or house_sites.size()!=2:house_sites=[[],[]]
 ruins=data.get("ruins",[])
 scars=data.get("scars",[])
 world_centers=data.get("world_centers",[])
 destroyed_total=int(data.get("destroyed_total",0))
 discovery_sites=data.get("discovery_sites",[])
 completed_visible=int(data.get("completed_visible",0))
 hazards=data.get("hazards",[])
 next_hazard=int(data.get("next_hazard",1))
 battle_count=int(data.get("battle_count",0))
 outposts=data.get("outposts",[])
 reset_visuals()
 for pending in data.get("pending_meteors",[]):
  if pending is Array and pending.size()==2:meteor(ground(float(pending[0]),float(pending[1])),true)
 var cam=data.get("camera",[])
 if cam.size()==5:
  focus=Vector3(float(cam[0]),0,float(cam[1]))
  azimuth=float(cam[2])
  pitch=clampf(float(cam[3]),.24,1.48)
  distance=clampf(float(cam[4]),3.0,220.0 if vast_world else 125.0)
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
 if not test_destruction():failed=true
 if not test_services():failed=true
 if not test_life_upgrade():failed=true
 if not test_integrated_upgrade():failed=true
 if not test_exchange_and_inventory():failed=true
 if not test_behavior_brain():failed=true
 if not test_culture_and_regions():failed=true
 if not test_ocean_systems():failed=true
 if not test_deep_simulation():failed=true
 if not test_industry_and_volume():failed=true
 if not test_continuous_systems():failed=true
 if not test_player_experience():failed=true
 if not test_frontier_origins():failed=true
 if not test_world_depth():failed=true
 if not test_living_legacy():failed=true
 if not test_live_world():failed=true
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
 left_panel.hide()
 right_panel.hide()
 focus=centers[0]
 distance=22
 pitch=.58
 selected=sim.people[0].id if not sim.people.is_empty() else -1
 for citizen in sim.people:
  if actors.has(citizen.id):Art.portrait(self,actors[citizen.id],citizen)
 refresh()
 update_camera()
 await get_tree().create_timer(.4).timeout
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://preview-gameplay.png")
 right_panel.show()
 refresh()
 await get_tree().create_timer(.25).timeout
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://preview-inspector.png")
 hud.hide()
 if actors.has(selected):
  focus=actors[selected].node.position
  distance=3.0
  pitch=.30
  update_camera()
  await get_tree().create_timer(.4).timeout
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://preview-creature.png")
 new_world(47,0,true,true)
 speed=0
 hud.hide()
 focus=Vector3.ZERO
 distance=125
 pitch=1.43
 azimuth=-.74
 update_camera()
 await get_tree().create_timer(.5).timeout
 await RenderingServer.frame_post_draw
 var region_err=get_viewport().get_texture().get_image().save_png("res://preview-archipelago.png")
 if region_err!=OK:err=region_err
 var pose_err=await capture_pose_gallery()
 if pose_err!=OK:err=pose_err
 new_world(47,0,true,true,true)
 speed=0
 hud.hide()
 for clan in range(2):
  sim.villages[clan].era=4
  sim.villages[clan].houses=12
  sync_houses(clan)
 districts.sync()
 focus=Vector3.ZERO
 distance=215
 pitch=1.42
 update_camera()
 await get_tree().create_timer(.5).timeout
 await RenderingServer.frame_post_draw
 var frontier_err=get_viewport().get_texture().get_image().save_png("res://preview-frontier.png")
 if frontier_err!=OK:err=frontier_err
 focus=centers[0]
 distance=20
 pitch=.66
 update_camera()
 await get_tree().create_timer(.4).timeout
 await RenderingServer.frame_post_draw
 var city_err=get_viewport().get_texture().get_image().save_png("res://preview-city.png")
 if city_err!=OK:err=city_err
 focus=cave.entrance()
 distance=24
 pitch=.78
 update_camera()
 await get_tree().create_timer(.3).timeout
 await RenderingServer.frame_post_draw
 var river_err=get_viewport().get_texture().get_image().save_png("res://preview-river.png")
 if river_err!=OK:err=river_err
 if cave.enter(true):
  await get_tree().create_timer(.4).timeout
  await RenderingServer.frame_post_draw
  var cave_err=get_viewport().get_texture().get_image().save_png("res://preview-cave.png")
  if cave_err!=OK:err=cave_err
  cave.leave()
 show_title_screen()
 await get_tree().create_timer(1.3).timeout
 await RenderingServer.frame_post_draw
 var title_err=get_viewport().get_texture().get_image().save_png("res://preview-title.png")
 if title_err!=OK:err=title_err
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
  var cost=18 if name_value in ["Meteorite","Tsunami","Vulcano","Resurrezione","Montagna","Lago","Incendio","Terremoto","Tornado","Epidemia"] else 9
  var display=name_value if name_value=="Osserva" else name_value+"  ·  "+str(cost)
  var b=button(power_grid,display,func():
   power=name_value
   power_label.text=name_value
   if hint!=null:hint.text=POWER_TIPS.get(name_value,"")
   for item in power_buttons:item.button_pressed=item.get_meta("power")==power)
  b.icon=power_icon(name_value)
  b.expand_icon=false
  b.toggle_mode=true
  b.set_pressed_no_signal(power==name_value)
  b.set_meta("power",name_value)
  b.tooltip_text=POWER_TIPS.get(name_value,"")
  power_buttons.append(b)
func show_help():
 open_dialog("GUIDA AL CREATORE","BENVENUTO IN GENESIS 47\n\n1. Osserva la vita: clicca un abitante o premi Casuale, poi Segui.\n2. Usa la mappa per raggiungere una zona.\n3. Scegli una categoria di poteri. Il numero indica il costo in energia. Clicca il mondo per intervenire.\n4. Accelera il tempo e controlla le scoperte.\n5. Rispondi ai segnali degli abitanti: pace, guerra e conoscenza possono modificare il mondo.\n\nWASD = movimento | rotella = zoom | trascina il destro = rotazione\nC = grotta (Grande frontiera) | P = poteri | L = leggenda\nSPAZIO = pausa | F1 = guida | F5 = salva | F9 = carica | F10 = cinema\n\nIl cervello comportamentale è integrato nel gioco. Non occorrono modelli, programmi esterni o Internet.\n\nOgni scenario ha un obiettivo nella barra inferiore. Puoi continuare anche dopo il finale.")
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
 for i in range(2):triangle_count+=LivingArt.streets(self,st,i)
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
 player_hud=not compact
 if is_instance_valid(left_panel):left_panel.visible=not compact
 if is_instance_valid(right_panel):right_panel.visible=not compact
 if is_instance_valid(map_panel):map_panel.visible=not compact
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
   if blocked_site(p):continue
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
 for i in range(6):
  var n=Node3D.new()
  ambient_root.add_child(n)
  n.position=Vector3(rng.randf_range(-75,75),rng.randf_range(18,28),rng.randf_range(-68,68))
  for j in range(5):
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
   puff.position=Vector3(cos(j*2.39996)*2.2,sin(j*1.7)*.35,sin(j*2.39996)*1.3)
   puff.scale=Vector3(5.5+float(j%3),1.0+float(j%2)*.5,3.8)
  clouds.append(n)

func update_clouds(delta:float):
 for n in clouds:
  if not is_instance_valid(n):continue
  n.visible=quality_mode>0 and distance>22 and distance<80
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
 sun.directional_shadow_max_distance=75.0 if quality_mode==1 else 115.0
 precipitation.amount=220 if quality_mode==0 else 420 if quality_mode==1 else 600
 if is_instance_valid(sea):sea.material_override.set_shader_parameter("detail_strength",.25 if quality_mode==0 else .70 if quality_mode==1 else 1.0)
 get_viewport().msaa_3d=Viewport.MSAA_4X if quality_mode==2 else Viewport.MSAA_2X if quality_mode==1 else Viewport.MSAA_DISABLED
 get_viewport().scaling_3d_scale=.85 if quality_mode==0 else 1.0

func restore_settings():
 if settings.load("user://genesis47_settings.cfg")!=OK:return
 apply_quality(int(settings.get_value("game","quality",1)))
 autosave_enabled=bool(settings.get_value("game","autosave",true))
 onboarding_enabled=bool(settings.get_value("game","onboarding",true))
 absent_progress=bool(settings.get_value("game","absence",false))
 volume_value=float(settings.get_value("game","volume",50))
 audio.volume_db=linear_to_db(maxf(.001,volume_value/100.0))-17
 audio.stream_paused=bool(settings.get_value("game","muted",false))

func store_settings():
 settings.set_value("game","quality",quality_mode)
 settings.set_value("game","autosave",autosave_enabled)
 settings.set_value("game","onboarding",onboarding_enabled)
 settings.set_value("game","absence",absent_progress)
 settings.set_value("game","volume",volume_value)
 settings.set_value("game","muted",audio.stream_paused)
 settings.save("user://genesis47_settings.cfg")

func notify_event(heading:String,message:String):
 if test_mode or not is_instance_valid(toast_panel):return
 toast_label.text=heading+"\n"+message
 toast_panel.show()
 toast_time=4.0

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
 if not test_mode:legend.meet(id,true)
 if player_hud:right_panel.show()
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
  LivingArt.plaza(self,settlement_root,i)
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
  if p.y<SEA+.7 or p.y>7.3 or not far_village(p,4.0) or not away_from_route(p,.8) or scarred(p):continue
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
 var steps=["1/5 · Sposta la vista con WASD, ruota tenendo premuto il destro e usa la rotella per avvicinarti.","2/5 · Clicca una creatura per conoscerla. Un doppio clic la segue; puoi anche usare Casuale e Segui.","3/5 · Premi P per aprire i poteri, scegli Vita o Guarigione e clicca sul terreno. Esc torna a Osserva.","4/5 · Premi L per leggere la Leggenda. Apri Vite per conoscere civiltà, scoperte e dialoghi.","5/5 · Usa Pausa e le velocità in basso. F5 salva, F9 carica, F6 avvia il tour. In Eternità non devi vincere."]
 onboarding_label.text=steps[clampi(onboarding_step,0,4)]
 if onboarding_step==2:left_panel.show()
 if onboarding_step==3:right_panel.show()

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
 new_world(47,0,true,true)
 autosave_enabled=false
 Engine.max_fps=0
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 speed=0
 for i in range(125):
  sim.daily()
  ocean.daily()
  apply_changes()
 apply_changes()
 for i in range(2):sync_houses(i)
 var info={"version":str(ProjectSettings.get_setting("application/config/version")),"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"driver":RenderingServer.get_video_adapter_api_version(),"window":str(DisplayServer.window_get_size()),"population":sim.people.size(),"colonies":ocean.colonies.size(),"ships":ocean.voyages.size(),"seed":47,"day":sim.day,"profiles":[]}
 info["active_simulation"]=true
 sim.spatial_autonomy=true
 speed=1.0
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
  info.profiles.append({"name":names[profile],"day":sim.day,"population":sim.people.size(),"fps_average":snappedf(1000/maxf(.01,mean_ms),.1),"fps_p99_equivalent":snappedf(1000/maxf(.01,p99),.1),"frames":samples.size()})
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
  var record={"version":str(ProjectSettings.get_setting("application/config/version")),"date":Time.get_datetime_string_from_system(),"tasks_completed_without_help":results,"notes":notes.text}
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
 if expanded_world and not ocean.enabled and h<SEA+.85:
  var q=Vector2(x,z)
  for link in REGION_BRIDGES:
   if q.distance_to(Geometry2D.get_closest_point_to_segment(q,link[0],link[1]))<1.35:return maxf(h,SEA+.85)
 if h<SEA+.55:
  for p in trade_route:
   if Vector2(x-p.x,z-p.z).length()<.65:return maxf(h,p.y)
 return h

func rebuild_navigation():
 var extent=94 if vast_world else 50
 nav_grid.region=Rect2i(-extent,-extent,extent*2+1,extent*2+1)
 nav_grid.cell_size=Vector2.ONE
 nav_grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 nav_grid.update()
 nav_grid.fill_solid_region(nav_grid.region,false)
 for z in range(-extent,extent+1):
  for x in range(-extent,extent+1):
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
   if houses[a.clan].is_empty():return c+offset*2.0
   var h:Vector3=houses[a.clan][int(a.id)%houses[a.clan].size()].node.position
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
  "social","aid","teach":
   if actors.has(int(a.task_target)):return actors[int(a.task_target)].node.position+offset*.7
   return c+offset*2
  "play":return c+Vector3(-3,0,3)+offset
  "explore":
   var best=INF
   var dest=c+Vector3(cos(angle+float(a.tasks_done)*1.7),0,sin(angle+float(a.tasks_done)*1.7))*8.0
   for landmark in discovery_sites:
    if landmark.found or (ocean.enabled and str(landmark.name) in REGION_NAMES.slice(1)):continue
    var q=ground(float(landmark.x),float(landmark.z))
    var d=flat_dist(q,c)
    if d<best and d<(120.0 if vast_world else 82.0 if expanded_world else 24.0):best=d;dest=q
   if not test_mode:
    if bool(a.get("separatist",false)) and legacy.societies[int(a.clan)].has("camp") and int(a.tasks_done)%3==0:
     var camp:Array=legacy.societies[int(a.clan)].camp
     return ground(float(camp[0]),float(camp[1]))
    for site in legacy.sites:
     if site.found:continue
     var p=ground(float(site.x),float(site.z))
     var d=flat_dist(p,c)
     if d<best:best=d;dest=p
   return dest
 return c+offset

func route_actor(a:Dictionary,r:Dictionary)->bool:
 var n:Node3D=r.node
 var start=near_cell(n.position)
 var goal:Vector3=task_destination(a)
 if sim.spatial_autonomy and a.task not in ["social","aid","teach","explore"]:
  if not claim_service(a,r):return false
  goal=services[str(a.station_id)].pos
 var finish=near_cell(goal)
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
 leave_interior(r)
 claims.erase(int(a.id))
 a.station_id=""
 if a.delivery and a.cargo!="":a.held_goods=a.cargo
 a.delivery=false
 a.cargo=""
 if sim.spatial_autonomy and a.task!="":sim.learn_action(a,str(a.task),-2.0)
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
 a.erase("industry_action")
 if sim.spatial_autonomy:sim.tick_needs(a,dt)
 if float(r.get("panic",0))>0:
  r.panic=maxf(0,float(r.panic)-dt)
  a.task_stage="Fugge"
  var target:Vector3=r.get("escape",n.position)
  var dir=target-n.position
  dir.y=0
  if dir.length()>.25:
   var next=n.position+dir.normalized()*minf(dt*4.2,dir.length())
   next.y=walking_height(next.x,next.z)
   if next.y>SEA+.18:n.position=next;n.rotation.y=atan2(dir.x,dir.z)
   return true
  return false
 if sim.spatial_autonomy and a.task not in ["eat","sleep","heal","social","aid"] and a.hunger<75 and a.fatigue<75 and a.health>45:
  if float(r.get("meeting_wait",0))>0:
   r.meeting_wait=maxf(0,float(r.meeting_wait)-dt)
   return false
 if float(r.get("retry",0))>0:
  r.retry=maxf(0,float(r.retry)-dt)
  return false
 if a.task!="" and a.task not in ["eat","sleep","heal"] and (a.hunger>=91 and sim.villages[a.clan].food>=1 or a.fatigue>=94 or a.health<35):
  cancel_task(a,r)
  return false
 if a.task=="":
  leave_interior(r)
  if sim.spatial_autonomy and a.held_goods=="":
   if not test_mode and not ocean.industry.jobs.has(str(int(a.id))):
    if morning_ritual(a,r,dt):return false
    var ritual=int(legend.ritual_advance(a,n,dt))
    if ritual>=0:
     r.planned_task=""
     return ritual==1
   var job=int(ocean.industry.advance(int(a.clan),a,n,dt))
   if job>=0:
    a.activity="Lavora in impresa" if job==0 else "Trasporta per impresa"
    r.planned_task=""
    return job==1
  if sim.spatial_autonomy and a.held_goods!="" and a.hunger<90 and a.fatigue<94 and a.health>=35 and nearest_service(a,"store",n.position)!="":
   sim.begin_task(a,{"kind":"farm" if a.held_goods=="Cibo" else "gather","target":-1,"duration":1.0,"reason":"Consegna il materiale conservato"})
   a.delivery=true
   a.cargo=a.held_goods
  else:sim.begin_task(a,sim.choose_task(a,available_actions(a,r) if sim.spatial_autonomy else {}))
 if sim.spatial_autonomy and a.task not in ["social","aid","teach","explore"] and not str(a.station_id).is_empty() and not services.has(str(a.station_id)):
  cancel_task(a,r)
  return false
 if sim.spatial_autonomy and claims.has(int(a.id)) and not service_open(str(claims[int(a.id)]),a):
  cancel_task(a,r)
  return false
 if a.task in ["social","aid","teach"] and not actors.has(int(a.task_target)):
  cancel_task(a,r)
  return false
 if str(r.get("planned_task",""))!=a.task or int(r.get("nav_version",-1))!=nav_version:
  leave_interior(r)
  if not route_actor(a,r):
   cancel_task(a,r)
   return false
  a.task_stage="Trasporta" if a.delivery else "In viaggio"
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
 if a.task in ["social","aid","teach"]:
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
  var other=actors[int(a.task_target)]
  other["meeting_wait"]=.4
  var face=partner.position-n.position
  n.rotation.y=atan2(face.x,face.z)
  partner.rotation.y=atan2(-face.x,-face.z)
 a.task_stage="Consegna" if a.delivery else "In corso"
 if a.task=="sleep" and sim.spatial_autonomy:enter_interior(a,r,dt)
 a.task_left=maxf(0,float(a.task_left)-dt)
 if a.task_left<=0:
  if sim.spatial_autonomy and a.task in ["farm","gather"] and not a.delivery:
   claims.erase(int(a.id))
   a.cargo="Cibo" if a.task=="farm" else "Legna"
   a.held_goods=a.cargo
   a.delivery=true
   a.station_id=""
   a.task_left=1.0
   a.task_stage="Trasporta"
   r.planned_task=""
   return false
  if sim.spatial_autonomy:
   var kind=str(a.task)
   var site=services.get(str(a.station_id),{})
   if kind=="house" and not site.is_empty() and sim.villages[a.clan].wood>=22:
    var q:Vector3=site.get("site",site.pos)
    house_sites[a.clan].append({"x":q.x,"z":q.z})
   var target_id=int(a.task_target)
   var delivering=bool(a.delivery)
   var coins_before=float(a.coins)
   if sim.complete_task(a):
    ocean.work_completed(a,kind,coins_before)
    if delivering:a.held_goods=""
    completed_visible+=1
    if kind=="explore":discover_near(a,n.position)
    if not test_mode and kind=="sleep":a["morning_stage"]=1
    if kind=="social" and not test_mode:
     life_bubble(n.position,str(a.special_memory).left(42),Color("d6edd0"))
     if actors.has(target_id):life_bubble(actors[target_id].node.position,str(sim.find(target_id).get("last_speech","Ti ascolto.")).left(42),Color("f2d4a4"))
    if kind=="house" and not test_mode:life_bubble(n.position,"NUOVA CASA",Color("f2d4a4"))
    if not test_mode and distance<40:spark(n.position+Vector3.UP*.45,Color("9bdfb6"),.28)
   leave_interior(r)
   claims.erase(int(a.id))
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

func flat_dist(a:Vector3,b:Vector3)->float:
 return Vector2(a.x-b.x,a.z-b.z).length()

func occupied_site(clan:int,q:Vector3)->bool:
 for site in house_sites[clan]:
  if Vector2(q.x-float(site.x),q.z-float(site.z)).length()<2.7:return true
 return false

func blocked_site(p:Vector3)->bool:
 for old in ruins:
  if Vector2(p.x-float(old.x),p.z-float(old.z)).length()<2.0:return true
 return scarred(p)

func scarred(p:Vector3)->bool:
 for mark in scars:
  if sim.day<int(mark.until) and Vector2(p.x-float(mark.x),p.z-float(mark.z)).length()<float(mark.r):return true
 return false

func rebuild_ruins():
 if not is_instance_valid(ruin_root):return
 for child in ruin_root.get_children():
  ruin_root.remove_child(child)
  child.queue_free()
 for old in ruins:
  var pos=ground(float(old.x),float(old.z))
  if pos.y<SEA+.1:continue
  var n=Node3D.new()
  ruin_root.add_child(n)
  n.position=pos
  block(n,Color("443d36"),Vector3(0,.04,0),Vector3(2.1,.08,1.8))
  for j in range(9):
   var angle=float(j)*2.39996
   var q=Vector3(cos(angle)*(.35+.08*j),.15,sin(angle)*(.35+.08*j))
   var chunk=block(n,Color("74675a").lerp(Color("a79a85"),float(j%3)/3),q,Vector3(.38,.19+.07*(j%3),.32))
   chunk.rotation=Vector3(.12*j,angle,.15)
  var post=block(n,Color("4b3930"),Vector3(-.7,.38,.52),Vector3(.16,.76,.18))
  post.rotation.z=.33

func disaster(p:Vector3,kind:String,radius:float,damage:float,terrain_delta:float,terrain_radius:float):
 var losses=[0,0]
 var destroyed=0
 var dead_count=0
 for i in range(2):
  for j in range(houses[i].size()-1,-1,-1):
   var home=houses[i][j]
   var pos:Vector3=home.node.position
   var dist=flat_dist(pos,p)
   if dist>radius+0.85:continue
   if kind=="Fulmine" and dist>2.4:continue
   var site:Dictionary=house_sites[i][j]
   var stress=damage if damage>=105 else damage*(1.0-.45*dist/maxf(.1,radius))
   if not Structure.stress(site,p,stress,kind,int(sim.villages[i].era)):
    show_structure(home.node,site)
    continue
   ruins.append({"x":pos.x,"z":pos.z,"clan":i,"until":sim.day+14})
   house_sites[i].remove_at(j)
   home.node.hide()
   home.node.queue_free()
   houses[i].remove_at(j)
   losses[i]+=1
   destroyed+=1
   spark(pos+Vector3.UP*.4,Color("d4a16f"),1.1)
  if losses[i]>0:
   var v=sim.villages[i]
   v.houses=house_sites[i].size()
   v.wood=maxf(0,float(v.wood)-losses[i]*8)
   v.food=maxf(0,float(v.food)-losses[i]*10)
   v["rebuild_after"]=sim.day+7
   for a in sim.people:
    if a.clan==i:
     a.mood=maxf(0,a.mood-8)
     sim.remember(a,"Il nostro villaggio è stato colpito da "+kind+".")
 for a in sim.people.duplicate():
  if not actors.has(a.id):continue
  var dist=flat_dist(actors[a.id].node.position,p)
  if dist>radius:continue
  var protection=float(legacy.societies[int(a.clan)].resistance) if not test_mode and kind in ["Meteorite","Fulmine","Vulcano","Tsunami"] else 0.0
  a.health-=damage*(1.0-.65*dist/radius)*(1-protection)
  a.stress=minf(100,float(a.stress)+60)
  if damage>=35 and a.health>0:a["scars"]=mini(3,int(a.get("scars",0))+1)
  a.special_memory="Sono sopravvissuto a "+kind
  a.special_until=sim.day+5
  if a.health>0 and sim.spatial_autonomy:
   var rr=actors[a.id]
   cancel_task(a,rr)
   var away:Vector3=rr.node.position-p
   away.y=0
   if away.length()<.1:away=Vector3.RIGHT
   rr["escape"]=land_near(p.x+away.normalized().x*(radius+2),p.z+away.normalized().z*(radius+2))
   rr["panic"]=3.0
  if a.health<=0:
   sim.die(a,kind.to_lower())
   dead_count+=1
  else:
   sim.adjust_trust(a,-10)
   sim.remember(a,"Sono sopravvissuto a "+kind+".")
 for post in outposts.duplicate():
  if flat_dist(p,Vector3(float(post.x),0,float(post.z)))<=radius:outposts.erase(post)
 rebuild_outposts()
 scars.append({"x":p.x,"z":p.z,"r":radius,"until":sim.day+28})
 if scars.size()>256:scars.pop_front()
 for child in scenery.get_children():
  if child.has_meta("vegetation") and flat_dist(child.position,p)<=radius:
   child.hide()
   child.queue_free()
 for q in timber_points.duplicate():
  if flat_dist(q,p)<=radius:timber_points.erase(q)
 for row in planted.duplicate():
  if Vector2(p.x-float(row.x),p.z-float(row.z)).length()<=radius:planted.erase(row)
 destroyed_total+=destroyed
 if not test_mode and damage>=65:districts.damage(p,radius)
 ocean.damage_colonies(p,radius,damage,kind)
 if not test_mode:debris.spawn(p,clampf(damage/50.0,.6,2.0),kind)
 if terrain_radius>0:alter_ground(p,terrain_delta,terrain_radius)
 rebuild_ruins()
 rebuild_roads()
 rebuild_farms()
 rebuild_meadow()
 nav_dirty=true
 services_dirty=true
 rebuild_navigation()
 rebuild_services()
 if not test_mode:
  legacy.record("Catastrofe",-1,-1,"%s: %d edifici perduti, %d vittime."%[kind,destroyed,dead_count],p)
  if flat_dist(p,focus)<35 and damage>=65:impact_shake=minf(1.0,damage/110.0)
 sim.log_event("%s: %d edifici distrutti, %d vittime."%[kind,destroyed,dead_count])
 apply_changes()
 refresh()
 notify_event(kind.to_upper(),"%d edifici distrutti · %d vittime"%[destroyed,dead_count])

func test_destruction()->bool:
 deformation.clear()
 new_world(47,0)
 if houses[0].is_empty() or houses[1].is_empty():return false
 var target:Vector3=houses[0][0].node.position
 var other_count=houses[1].size()
 var height=height_at(target.x,target.z)
 unlimited=true
 power="Meteorite"
 divine(target)
 if not ruins.is_empty():return false
 update_effects(1.2)
 if destroyed_total<1 or ruins.is_empty() or houses[1].size()!=other_count or height_at(target.x,target.z)>=height-2:return false
 for home in houses[0]:
  if flat_dist(home.node.position,target)<7:return false
 var expected=destroyed_total
 var file="user://genesis47_disaster_test.json"
 if not save_path(file,false) or not load_path(file):return false
 if destroyed_total!=expected or ruins.is_empty() or houses[1].size()!=other_count:return false
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(file+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(file+ext))
 print("DESTRUCTION_TEST destroyed=",destroyed_total," ruins=",ruins.size()," untouched_other=",other_count)
 power="Osserva"
 return true

func site_key(kind:String,clan:int,p:Vector3)->String:
 return "%s:%d:%d:%d"%[kind,clan,roundi(p.x*10),roundi(p.z*10)]

func register_service(kind:String,clan:int,p:Vector3,capacity:int,caption:String,draw=true)->String:
 var cell=near_cell(p)
 if not nav_grid.region.has_point(cell):return ""
 var q=Vector3(cell.x,walking_height(cell.x,cell.y),cell.y)
 if flat_dist(q,p)>3.5 or scarred(q) or scarred(p):return ""
 var key=site_key(kind,clan,p)
 services[key]={"kind":kind,"clan":clan,"pos":q,"capacity":capacity,"site":p}
 if draw:
  var node=Node3D.new()
  service_root.add_child(node)
  node.position=q
  var tint=Color("7bbcb1") if clan==0 else Color("dcac76")
  match kind:
   "eat","store":
    for side in [-1,1]:
     block(node,Color("92704e"),Vector3(-.6+side*.52,.70,-.35),Vector3(.07,1.4,.07))
     block(node,Color("92704e"),Vector3(-.6+side*.52,.70,.35),Vector3(.07,1.4,.07))
    for stripe in range(5):block(node,tint if stripe%2==0 else Color("e9d9b3"),Vector3(-1.05+stripe*.22,1.44,0),Vector3(.23,.075,.92))
    block(node,Color("876748"),Vector3(-.6,.25,0),Vector3(.9,.5,.72))
    for j in range(3):
     sphere(node,Color("e6b962") if kind=="eat" else Color("a38460"),Vector3(-.8+j*.22,.57,0),Vector3(.18,.18,.18))
   "sleep":
    block(node,Color("84674b"),Vector3(-.5,.10,0),Vector3(.65,.18,.95))
    block(node,tint,Vector3(-.5,.23,0),Vector3(.58,.13,.83))
    block(node,Color("efe1bc"),Vector3(-.5,.31,-.29),Vector3(.45,.10,.22))
   "heal":
    block(node,Color("dfd8bc"),Vector3(-.6,.35,0),Vector3(.85,.7,.8))
    block(node,Color("75b79e"),Vector3(-.6,.75,0),Vector3(1.05,.16,.9))
    block(node,Color("e78e79"),Vector3(-.6,.45,.43),Vector3(.13,.34,.04))
    block(node,Color("e78e79"),Vector3(-.6,.45,.45),Vector3(.34,.13,.04))
   "farm":
    for j in range(4):
     block(node,Color("6d5238"),Vector3(-.65,.04,(j-1.5)*.30),Vector3(.6,.08,.25))
     sphere(node,Color("87aa56"),Vector3(-.65,.23,(j-1.5)*.30),Vector3(.19,.37,.19))
   "research":
    block(node,Color("795c45"),Vector3(-.6,.4,0),Vector3(.8,.13,.7))
    block(node,Color("decba4"),Vector3(-.6,.5,0),Vector3(.40,.09,.32))
   "craft":
    block(node,Color("61584d"),Vector3(-.6,.32,0),Vector3(.8,.62,.65))
    block(node,Color("a6b0b4"),Vector3(-.6,.70,0),Vector3(.48,.15,.26))
    block(node,Color("9e734a"),Vector3(-.6,.80,.1),Vector3(.45,.06,.06))
   "guard":
    cone(node,tint,Vector3(-.55,.8,0),.10,1.6,.04,6)
   "build","house":
    block(node,Color("9c7953"),Vector3(-.65,.07,0),Vector3(.85,.14,.85))
    for j in range(3):
     block(node,Color("b18a59"),Vector3(-.65,.21+j*.12,0),Vector3(.75,.1,.17))
   "play":
    sphere(node,tint,Vector3(-.6,.18,0),Vector3(.35,.35,.35))
  var label=Label3D.new()
  node.add_child(label)
  label.position=Vector3(-.55,1.05,0)
  label.text=caption
  label.font_size=29
  label.pixel_size=.008
  label.outline_size=6
  label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  label.modulate=Color("f4e7c5")
  services[key]["label"]=label
  services[key]["node"]=node
  services[key]["caption"]=caption
  if kind=="house":
   var frame=Node3D.new()
   node.add_child(frame)
   for xx in [-.9,.9]:
    for zz in [-.9,.9]:block(frame,Color("b08c62"),Vector3(xx,.6,zz),Vector3(.10,1.2,.10))
   block(frame,Color("c8ae80"),Vector3(0,1.2,-.9),Vector3(1.9,.13,.13))
   block(frame,Color("c8ae80"),Vector3(0,1.2,.9),Vector3(1.9,.13,.13))
   frame.hide()
   services[key]["frame"]=frame
 return key

func rebuild_services():
 if not is_instance_valid(service_root) or centers.size()!=2:return
 for child in service_root.get_children():
  service_root.remove_child(child)
  child.queue_free()
 var old_claims=claims.duplicate()
 for a in sim.people:
  if actors.has(a.id) and actors[a.id].has("door_position") and a.task!="sleep":leave_interior(actors[a.id])
 services.clear()
 claims.clear()
 for i in range(2):
  var c:Vector3=centers[i]
  for j in range(4):
   var angle=float(j)*TAU/4+.5
   var q=c+Vector3(cos(angle),0,sin(angle))*2.7
   register_service("eat",i,q,3,"RISTORO")
  register_service("store",i,c+Vector3(-2.6,0,3.2),4,"MAGAZZINO")
  register_service("heal",i,c+Vector3(2.5,0,-2.4),3,"CURE")
  register_service("research",i,c+Vector3(-3.0,0,-3.0),3,"RICERCA")
  register_service("play",i,c+Vector3(-3.0,0,3.0),4,"PIAZZA")
  register_service("build",i,c+Vector3(3.0,0,-3.0),3,"OPERA CIVILE")
  if sim.villages[i].tech>=2:register_service("craft",i,c+Vector3(-4.5,0,0),2,"OFFICINA")
  register_service("guard",i,c.lerp(centers[1-i],.47),4,"CONFINE")
  for home in houses[i]:
   var q:Vector3=home.node.position
   var door=q+(c-q).normalized()*2.0
   var key=register_service("sleep",i,door,4,"DIMORA",false)
   if key!="":
    services[key]["home"]=site_key("home",i,q)
    services[key]["building"]=home.node
  for q in farm_points[i]:register_service("farm",i,q,3,"CAMPO")
  for post in outposts:
   if int(post.clan)==i:register_service("farm",i,ground(float(post.x),float(post.z)),2,"AVAMPOSTO",false)
  if sim.villages[i].era<2:
   for j in range(3):
    var q=c+Vector3(4.0+j*2.2,0,4.5 if i==0 else -4.5)
    register_service("farm",i,q,3,"RACCOLTA")
  for j in range(360 if vast_world else 180):
   var q=house_location(i,j)
   if q.y>SEA+.7 and not occupied_site(i,q) and not blocked_site(q):
    if register_service("house",i,q,1,"CANTIERE")!="":break
  for q in timber_points:
   if flat_dist(q,c)<24:register_service("gather",i,q+(c-q).normalized()*.75,1,"LEGNA",false)
 districts.register_stations()
 assign_homes()
 for id in old_claims:
  var citizen=sim.find(int(id))
  var key=str(old_claims[id])
  if not citizen.is_empty() and citizen.station_id==key and service_open(key,citizen):claims[int(id)]=key
 for a in sim.people:
  if actors.has(a.id) and not claims.has(int(a.id)) and a.task not in ["social","aid","teach","explore"]:actors[a.id]["planned_task"]=""
 services_dirty=false
 update_service_labels()

func assign_homes():
 var usage={}
 for a in sim.people:
  var key=str(a.get("home_key",""))
  if not services.has(key) or int(services[key].clan)!=int(a.clan) or str(services[key].kind)!="sleep" or services[key].get("temporary",false) or int(usage.get(key,0))>=4:
   a.home_key=""
  else:usage[key]=int(usage.get(key,0))+1
 for a in sim.people:
  if a.home_key!="":continue
  var family=sim.find(int(a.partner))
  if family.is_empty() and not a.parents.is_empty():family=sim.find(int(a.parents[0]))
  var preferred=str(family.get("home_key",""))
  if services.has(preferred) and int(services[preferred].clan)==int(a.clan) and int(usage.get(preferred,0))<4:
   a.home_key=preferred
   usage[preferred]=int(usage.get(preferred,0))+1
   continue
  for key in services:
   var row=services[key]
   if row.kind=="sleep" and row.clan==a.clan and not row.get("temporary",false) and int(usage.get(key,0))<4:
    a.home_key=key
    usage[key]=int(usage.get(key,0))+1
    break

func service_open(key:String,a:Dictionary)->bool:
 if not services.has(key):return false
 var row=services[key]
 if row.clan!=a.clan:return false
 var used=0
 var meals=0
 for id in claims:
  if int(id)==int(a.id):continue
  if claims[id]==key:used+=1
  if services.has(claims[id]) and services[claims[id]].kind=="eat" and services[claims[id]].clan==a.clan:meals+=1
 if used>=int(row.capacity):return false
 if row.kind=="eat" and sim.villages[a.clan].food<meals+1:return false
 if row.kind=="house" and sim.villages[a.clan].wood<22:return false
 if row.kind=="craft" and sim.villages[a.clan].wood<4:return false
 if row.kind=="sleep" and a.home_key!=key and not (a.home_key=="" and row.get("temporary",false)):return false
 if row.kind=="house" and sim.villages[a.clan].houses>=mini(sim.housing_limit,3+int(sim.count(a.clan)/4)+sim.villages[a.clan].era):return false
 return true

func nearest_service(a:Dictionary,kind:String,origin:Vector3)->String:
 var best=""
 var cost=INF
 for key in services:
  var row=services[key]
  if row.kind!=kind or not service_open(key,a):continue
  var d=flat_dist(origin,row.pos)
  if d<cost:cost=d;best=key
 return best

func available_actions(a:Dictionary,r:Dictionary)->Dictionary:
 var result={"explore":8.0,"social":4.0,"aid":4.0,"teach":4.0}
 var origin:Vector3=r.node.position
 for kind in ["eat","sleep","heal","farm","gather","research","build","house","play","craft","guard"]:
  var key=nearest_service(a,kind,origin)
  if key!="":result[kind]=flat_dist(origin,services[key].pos)
 # Emergency rest on safe ground, even when every dwelling is gone.
 if not result.has("sleep") and a.home_key=="":result.sleep=0.0
 if nearest_service(a,"store",origin)=="":
  result.erase("farm")
  result.erase("gather")
 return result

func claim_service(a:Dictionary,r:Dictionary)->bool:
 var kind="store" if a.delivery else str(a.task)
 var key=str(a.station_id)
 if key=="" or not services.has(key) or services[key].kind!=kind or not service_open(key,a):
  key=nearest_service(a,kind,r.node.position)
 if key=="" and kind=="sleep" and a.home_key=="":
  key=register_service("sleep",a.clan,r.node.position,1,"RIPARO",false)
  if key!="":services[key]["temporary"]=true
 if key=="":return false
 claims[int(a.id)]=key
 a.station_id=key
 return true

func update_action_visual(a:Dictionary,r:Dictionary,moving:bool):
 var active=str(a.get("industry_action",a.task))
 var marker:Label3D=r.action_marker
 var prop:Node3D=r.action_prop
 var shown=active!="" and (a.task_stage in ["In corso","Consegna"] or a.delivery)
 marker.visible=(shown or a.task_stage=="Fugge") and distance<20 and not photo_mode and (show_labels or selected==a.id or a.task_stage=="Fugge")
 var marks={"craft":"OFFICINA","teach":"FAMIGLIA","guard":"GUARDIA","eat":"CIBO","sleep":"Zzz","heal":"+","farm":"RACCOLTO","gather":"LEGNA","research":"STUDIO","build":"LAVORO","house":"CANTIERE","social":"CIAO","aid":"+","play":"SVAGO","explore":"ESPLORA"}
 marker.text="FUGA!" if a.task_stage=="Fugge" else "TRASPORTO" if a.delivery else str(marks.get(active,""))
 marker.modulate=Color("a8e1b7") if active in ["heal","aid","farm"] else Color("f1d5a1")
 var visual="cargo_industrial" if active=="deliver" else ("cargo_"+str(a.cargo) if a.delivery else active if a.task_stage=="In corso" else "cargo_"+str(a.held_goods) if a.held_goods!="" else "")
 if str(r.get("prop_kind",""))!=visual:
  r["prop_kind"]=visual
  for child in prop.get_children():
   prop.remove_child(child)
   child.queue_free()
  match visual:
   "eat","cargo_Cibo":
    block(prop,Color("96714b"),Vector3.ZERO,Vector3(.34,.15,.27))
    for j in range(3):sphere(prop,Color("e4b65e"),Vector3((j-1)*.11,.12,0),Vector3(.13,.13,.13))
   "cargo_Legna":
    for j in range(3):block(prop,Color("9f774e"),Vector3(0,j*.09,0),Vector3(.48,.075,.11))
   "cargo_industrial":block(prop,Color("b49a73"),Vector3.ZERO,Vector3(.35,.26,.30))
   "gather","build","house","craft","industry":
    block(prop,Color("98704c"),Vector3(0,.08,0),Vector3(.075,.54,.075))
    block(prop,Color("a6b5b7"),Vector3(.09,.32,0),Vector3(.25,.13,.08))
   "guard":
    block(prop,Color("a7b4b7"),Vector3(0,.22,0),Vector3(.055,.55,.045))
    block(prop,Color("b1956c"),Vector3(0,-.06,0),Vector3(.21,.06,.08))
   "teach":block(prop,Color("efe0b7"),Vector3.ZERO,Vector3(.32,.07,.25))
   "research":block(prop,Color("e1d2a9"),Vector3.ZERO,Vector3(.38,.07,.30))
   "heal","aid":
    block(prop,Color("e6e3cf"),Vector3.ZERO,Vector3(.25,.24,.21))
    block(prop,Color("d37d6c"),Vector3(0,0,.12),Vector3(.05,.16,.025))
    block(prop,Color("d37d6c"),Vector3(0,0,.135),Vector3(.16,.05,.025))
   "play":sphere(prop,Color("e5bd70"),Vector3.ZERO,Vector3(.23,.23,.23))
 if distance<22:
  var mouth=r.get("mouth")
  if is_instance_valid(mouth):mouth.scale.y=.12 if a.emotion=="Felice" else .065+absf(sin(r.phase*3))*.055 if active=="social" else .045
  var brows=r.get("brows",[])
  for j in range(brows.size()):brows[j].rotation.z=(1 if j==0 else -1)*(.25 if a.emotion in ["Triste","In lutto","Spaventato"] else -.10)
 if not moving and a.task_stage=="In corso" and not r.arms.is_empty():
  match active:
   "eat":
    r.arms[0].rotation.x=-1.0+sin(r.phase*4)*.4
    r.arms[1].rotation.x=-.7
   "gather","house","build","craft","guard":
    r.arms[0].rotation.x=-1.15+sin(r.phase*5)*.8
    r.arms[1].rotation.x=-.55+sin(r.phase*5)*.4
   "farm":
    r.body.rotation.x=.42+sin(r.phase*3)*.12
    r.arms[0].rotation.x=-.8+sin(r.phase*4)*.5
   "social","aid","teach":
    r.arms[0].rotation.z=-.35+sin(r.phase*3)*.3
    r.arms[1].rotation.x=-.6+sin(r.phase*2)*.35
   "play":r.body.position.y=.09+absf(sin(r.phase*4))*.13
 else:
  for arm in r.arms:arm.rotation.z=0.0
 if not moving and a.task_stage=="In corso" and not r.arms.is_empty():
  match active:
   "research":
    r.body.rotation.x=lerpf(r.body.rotation.x,.19,.25)
    r.arms[0].rotation.x=-.85+sin(r.phase*3)*.12
    r.arms[1].rotation.x=-.85
   "heal":
    r.arms[0].rotation.x=-1.1+sin(r.phase*2)*.18
    r.arms[1].rotation.x=-.50
   "explore":
    r.body.rotation.z=sin(r.phase*1.5)*.13
    r.arms[0].rotation.x=-.75
 if not moving and active=="sleep" and a.task_stage=="In corso":
  r.body.rotation.x=lerpf(r.body.rotation.x,PI*.42,.25)
  r.body.position.y=.14
  for eye in r.get("eyes",[]):eye.scale.y=.10

func test_services()->bool:
 deformation.clear()
 new_world(47,0)
 sim.spatial_autonomy=true
 if services.is_empty() or not service_root.is_inside_tree():return false
 var a=sim.people[0]
 var key=nearest_service(a,"eat",centers[a.clan])
 if key=="" or a.home_key=="":return false
 var row=services[key]
 for i in range(int(row.capacity)):claims[9000+i]=key
 if service_open(key,a):return false
 claims.clear()
 if not service_open(key,a):return false
 # Verify a gatherer produces no inventory before reaching the warehouse.
 a.hunger=0.0
 a.fatigue=0.0
 a.health=100.0
 sim.begin_task(a,{"kind":"farm","target":-1,"duration":.2,"reason":"test"})
 var original_food=float(sim.villages[a.clan].food)
 var carried=false
 for j in range(600):
  advance_actor_task(a,actors[a.id],.1)
  if a.delivery:
   carried=true
   if sim.villages[a.clan].food!=original_food:return false
  if a.task=="":break
 if not carried or a.last_task!="farm" or sim.villages[a.clan].food<=original_food:return false
 var home=str(a.home_key)
 var q:Vector3=services[home].pos
 disaster(q,"Fulmine",2.4,0.0,0.0,0.0)
 if services.has(home):return false
 var sample=Sim.new()
 sample.start(47,0)
 sample.spatial_autonomy=true
 var food=float(sample.villages[0].food)
 var wood=float(sample.villages[0].wood)
 sample.daily()
 if sample.villages[0].food!=food or sample.villages[0].wood!=wood:return false
 print("SERVICES_TEST reservation=true housing=true transport=true no_passive_production=true")
 sim.spatial_autonomy=false
 return true

func life_bubble(p:Vector3,message:String,tint:Color):
 if test_mode or effects.size()>90:return
 var label=Label3D.new()
 effects_root.add_child(label)
 label.position=p+Vector3.UP*1.85
 label.text=message
 label.modulate=tint
 label.font_size=32
 label.pixel_size=.007
 label.outline_size=7
 label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 effects.append({"kind":"bubble","node":label,"life":3.5,"max":3.5})

func update_service_labels():
 for key in services:
  var row=services[key]
  if is_instance_valid(row.get("label")):row.label.visible=show_world_labels and distance<28 and not photo_mode

func update_house_views():
 var a=sim.find(selected)
 var selected_home=str(a.get("home_key",""))
 var selected_building=services.get(selected_home,{}).get("building")
 for clan in range(2):
  for home in houses[clan]:
   var n:Node3D=home.node
   var interior=n.get_meta("interior",null)
   var cover=n.get_meta("cover",null)
   if not is_instance_valid(interior) or not is_instance_valid(cover):continue
   var cutaway=distance<12 and n==selected_building
   cover.visible=not cutaway
   interior.visible=cutaway

func enter_interior(a:Dictionary,r:Dictionary,dt:float):
 var row=services.get(str(a.station_id),{})
 var building=row.get("building")
 if not is_instance_valid(building):return
 var n:Node3D=r.node
 if not r.has("door_position"):r["door_position"]=n.position
 var slot_index=0
 for citizen in sim.people:
  if citizen.id==a.id:break
  if citizen.home_key==a.home_key:slot_index+=1
 slot_index=posmod(slot_index,4)
 var local=Vector3(-.69 if slot_index%2==0 else .69,.38,-.60+float(int(slot_index/2))*.98)
 var bed:Vector3=building.to_global(local)
 n.position=n.position.move_toward(bed,dt*2.5)
 n.rotation.y=building.rotation.y

func leave_interior(r:Dictionary):
 if r.has("door_position"):
  r.node.position=r.door_position
  r.erase("door_position")

func rebuild_discoveries():
 if not is_instance_valid(discovery_root):return
 for child in discovery_root.get_children():
  discovery_root.remove_child(child)
  child.queue_free()
 if discovery_sites.is_empty():
  for i in range(2):
   var c:Vector3=centers[i]
   for j in range(3):
    var angle=(j*2.1+i)*1.1
    var q=land_near(c.x+cos(angle)*15,c.z+sin(angle)*15)
    if flat_dist(q,c)>7:discovery_sites.append({"x":q.x,"z":q.z,"found":false,"name":["Pietra antica","Fonte luminosa","Radura sacra"][j]})
  if expanded_world:
   for i in range(1,REGION_POINTS.size()):
    var point:Vector2=REGION_POINTS[i]
    discovery_sites.append({"x":point.x,"z":point.y,"found":false,"name":REGION_NAMES[i]})
  if vast_world:
   for i in range(Frontier.POINTS.size()):
    var p:Vector2=Frontier.POINTS[i]
    discovery_sites.append({"x":p.x,"z":p.y,"found":false,"name":Frontier.NAMES[i]})
  if ocean.enabled:
   for spec in [[-20,-17,"Arco dei titani"],[20,-15,"Terrazze cremisi"],[-5,24,"Fonte delle origini"],[24,15,"Cerchio degli antichi"]]:
    var p=land_near(float(spec[0]),float(spec[1]))
    if p.y>SEA+.4 and far_village(p,6):discovery_sites.append({"x":p.x,"z":p.z,"found":false,"name":spec[2]})
 for row in discovery_sites:
  var q=ground(float(row.x),float(row.z))
  if q.y<SEA+.3:continue
  var n=Node3D.new()
  discovery_root.add_child(n)
  n.position=q
  if str(row.name)=="Arco dei titani":
   for side in [-1,1]:cone(n,Color("8c9991"),Vector3(side*.65,1.0,0),.38,2.0,.26,6)
   block(n,Color("aab5a5"),Vector3(0,2.02,0),Vector3(1.95,.47,.63))
  elif str(row.name)=="Fonte delle origini":
   cone(n,Color("748781"),Vector3(0,.12,0),1.0,.24,1.0,12)
   cone(n,Color("61aab4"),Vector3(0,.25,0),.82,.045,.82,16,.15)
   sphere(n,Color("d0e5d6"),Vector3(0,.55,0),Vector3(.11,.65,.11),.3)
  elif str(row.name)=="Cerchio degli antichi":
   for i in range(7):
    var angle=i*TAU/7
    cone(n,Color("9c9e8c"),Vector3(cos(angle)*1.0,.60,sin(angle)*1.0),.21,1.2,.12,6)
   sphere(n,Color("e7cc92"),Vector3.UP*.46,Vector3(.38,.62,.38),.35)
  elif str(row.name)=="Terrazze cremisi":
   for i in range(3):block(n,Color("b38a62"),Vector3(0,.15+i*.27,0),Vector3(2.1-i*.48,.30,1.7-i*.38))
   cone(n,Color("d3ae73"),Vector3.UP*1.02,.27,.55,.08,7)
  else:
   cone(n,Color("777e79"),Vector3(0,.38,0),.42,.76,.15,6)
   sphere(n,Color("a6dfc8") if row.found else Color("d5b66d"),Vector3(0,.9,0),Vector3(.23,.34,.23),.8)
  if row.found:
   var tag=Label3D.new()
   n.add_child(tag)
   tag.position.y=1.3
   tag.text=str(row.name)
   tag.font_size=24
   tag.pixel_size=.008
   tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED

func discover_near(a:Dictionary,p:Vector3):
 if not test_mode:legacy.discover(a,p)
 for row in discovery_sites:
  if row.found or (ocean.enabled and str(row.name) in REGION_NAMES.slice(1)) or flat_dist(p,Vector3(float(row.x),0,float(row.z)))>2.1:continue
  row.found=true
  sim.villages[a.clan].knowledge+=8
  if sim.villages[a.clan].era>=2 and outposts.size()<8 and not scarred(p):
   var exists=false
   for post in outposts:
    if flat_dist(p,Vector3(float(post.x),0,float(post.z)))<6:exists=true
   if not exists:
    outposts.append({"x":p.x,"z":p.z,"clan":a.clan})
    rebuild_outposts()
    services_dirty=true
    sim.log_event(a.name+" fonda un avamposto.")
  a.special_memory="Ho scoperto "+str(row.name)
  a.special_until=sim.day+6
  sim.milestone(a,"Esplorazione",a.special_memory)
  sim.log_event(a.name+" scopre "+str(row.name)+".")
  if not test_mode:legend.discovered(a,str(row.name),p)
  rebuild_discoveries()
  life_bubble(p,"SCOPERTA!",Color("b2e5ca"))
  break

func test_life_upgrade()->bool:
 new_world(47,0)
 sim.spatial_autonomy=true
 var a=sim.people[0]
 var friend=sim.people[1]
 a.friend=friend.id
 friend.friend=a.id
 sim.die(friend,"test")
 sim.tick_needs(a,.1)
 if a.emotion!="In lutto" or a.stress<30:return false
 apply_changes()
 var home=str(a.home_key)
 if not services.has(home):return false
 var building=services[home].get("building")
 if not is_instance_valid(building) or not building.has_meta("interior"):return false
 if discovery_sites.is_empty():return false
 var mark=discovery_sites[0]
 var old_knowledge=float(sim.villages[a.clan].knowledge)
 discover_near(a,Vector3(float(mark.x),0,float(mark.z)))
 if not mark.found or sim.villages[a.clan].knowledge!=old_knowledge+8:return false
 print("LIFE_UPGRADE_TEST grief=true interior=true discovery=true")
 sim.spatial_autonomy=false
 return true

func rebuild_outposts():
 if not is_instance_valid(outpost_root):return
 for child in outpost_root.get_children():
  outpost_root.remove_child(child)
  child.queue_free()
 for post in outposts:
  var q=ground(float(post.x),float(post.z))
  if q.y<SEA+.2:continue
  var n=Node3D.new()
  outpost_root.add_child(n)
  n.position=q
  var tint=Color("79b9a7") if int(post.clan)==0 else Color("d9ac75")
  cone(n,Color("8b6c4d"),Vector3(0,.7,0),.08,1.4,.04,6)
  block(n,tint,Vector3(.36,1.15,0),Vector3(.72,.40,.05))
  block(n,Color("8b765a"),Vector3(-.45,.15,.25),Vector3(.75,.30,.7))
  for j in range(5):sphere(n,Color("b6cc75"),Vector3((j-2)*.25,.20,-.55),Vector3(.18,.32,.18))
  var tag=Label3D.new()
  n.add_child(tag)
  tag.text="AUTONOMISTI" if bool(post.get("autonomist",false)) else "AVAMPOSTO"
  tag.font_size=24
  tag.pixel_size=.007
  tag.position.y=1.7
  tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED

func update_worksites():
 for key in services:
  var row=services[key]
  if not is_instance_valid(row.get("frame")):continue
  var progress=0.0
  for id in claims:
   if claims[id]!=key:continue
   var a=sim.find(int(id))
   if not a.is_empty() and a.task_stage=="In corso":progress=clampf(1.0-float(a.task_left)/6.0,0,1)
  row.frame.visible=progress>0
  row.frame.scale.y=maxf(.12,progress)

func warn_near(p:Vector3,radius:float):
 for a in sim.people:
  if not actors.has(a.id):continue
  var r=actors[a.id]
  var q:Vector3=r.node.position
  if flat_dist(q,p)>radius:continue
  cancel_task(a,r)
  var away=q-p
  away.y=0
  if away.length()<.05:away=Vector3.RIGHT
  r["escape"]=land_near(p.x+away.normalized().x*(radius+3),p.z+away.normalized().z*(radius+3))
  r["panic"]=2.5
  a.stress=minf(100,a.stress+25)

func start_hazard(kind:String,p:Vector3,duration:float):
 if hazards.size()>=12:return
 var id=next_hazard
 next_hazard+=1
 hazards.append({"id":id,"kind":kind,"x":p.x,"z":p.z,"life":duration,"age":0.0,"pulse":0.0,"hit":[]})
 rebuild_hazards()

func rebuild_hazards():
 if not is_instance_valid(hazard_root):return
 for child in hazard_root.get_children():
  hazard_root.remove_child(child)
  child.queue_free()
 hazard_nodes.clear()
 for h in hazards:
  var n=Node3D.new()
  hazard_root.add_child(n)
  n.position=ground(float(h.x),float(h.z))
  hazard_nodes[int(h.id)]=n
  match str(h.kind):
   "fire":
    for j in range(5):
     var q=Vector3(cos(j*2.4)*.75,.35,sin(j*2.4)*.75)
     cone(n,Color("f0803c"),q,.36,1.0,.035,8,1.0)
     cone(n,Color("ffdb7a"),q*.8,.20,.65,.02,8,1.2)
   "tornado":
    for j in range(12):
     var rad=.25+float(j)*.13
     sphere(n,Color("a7b5b5").lerp(Color("d6dcd6"),float(j)/12),Vector3(cos(j*1.6)*rad,float(j)*.31,sin(j*1.6)*rad),Vector3(1.2, .58, 1.2))
   "flood":
    for j in range(16):
     var angle=j*TAU/16
     sphere(n,Color("63b4cc"),Vector3(cos(angle),.3,sin(angle)),Vector3(1.0,.6,1.0),.1)

func update_hazards(dt:float):
 if hazards.is_empty():return
 var changed=false
 for h in hazards.duplicate():
  var rain=sim.weather_name=="Pioggia" or sim.weather_name=="Neve"
  var decay=2.8 if h.kind=="fire" and rain else 1.0
  h.life=float(h.life)-dt*decay
  h.age=float(h.age)+dt
  h.pulse=float(h.pulse)+dt
  if h.life<=0:
   hazards.erase(h)
   changed=true
   continue
  var pos=ground(float(h.x),float(h.z))
  if h.kind=="tornado":
   var wind=Vector2(cos(float(sim.day)*.17+float(sim.seed_value)*.01),sin(float(sim.day)*.17+float(sim.seed_value)*.01))
   h.x=clampf(float(h.x)+dt*(wind.x*.8+.25),-48,48)
   h.z=clampf(float(h.z)+dt*(wind.y*.8+sin(float(h.age))*.25),-48,48)
   pos=ground(float(h.x),float(h.z))
  var n=hazard_nodes.get(int(h.id))
  if is_instance_valid(n):
   n.position=pos
   n.rotation.y+=dt*3.0
   if h.kind=="fire":n.scale=Vector3.ONE*(1.0+float(h.age)*.09)
   elif h.kind=="flood":n.scale=Vector3(1.0+float(h.age)*1.8,1,1.0+float(h.age)*1.8)
  if h.pulse>=2.0:
   h.pulse=0.0
   var radius=3.0+float(h.age)*(.08 if rain else .22) if h.kind=="fire" else 3.5 if h.kind=="tornado" else minf(11.0,2.0+float(h.age)*1.8)
   var cell=site_key(str(h.kind),0,pos)
   if not h.hit.has(cell) or h.kind in ["flood","fire"]:
    if not h.hit.has(cell):h.hit.append(cell)
    disaster(pos,"Incendio" if h.kind=="fire" else "Tornado" if h.kind=="tornado" else "Tsunami",radius,14.0 if h.kind=="fire" and rain else 28.0,0.0,0.0)
 if changed:rebuild_hazards()

func spatial_society():
 if not sim.spatial_autonomy:return
 var living=sim.people.duplicate()
 for a in living:
  if not actors.has(a.id):continue
  if a.sick>0:
   for b in living:
    if b.id==a.id or b.sick>0 or not actors.has(b.id):continue
    if flat_dist(actors[a.id].node.position,actors[b.id].node.position)<1.6 and rng.randf()<.025:
     b.sick=5
     b.stress=minf(100,b.stress+12)
     if not test_mode:life_bubble(actors[b.id].node.position,"MALATTIA",Color("adc277"))
  if sim.peace>=25 or a.task!="guard" or a.health<40:continue
  for b in living:
   if b.clan==a.clan or not actors.has(b.id) or b.health<=0:continue
   if flat_dist(actors[a.id].node.position,actors[b.id].node.position)<1.8:
    b.health=maxf(0,b.health-7.0)
    a.stress=minf(100,a.stress+4)
    b.stress=minf(100,b.stress+12)
    battle_count+=1
    if not test_mode:
     spark(actors[b.id].node.position+Vector3.UP*.6,Color("e9ab79"),.42)
     life_bubble(actors[b.id].node.position,"SCONTRO",Color("edaa84"))
    if b.health<=0:sim.die(b,"scontro")
    break
 if not sim.changes.is_empty():apply_changes()

func test_integrated_upgrade()->bool:
 new_world(47,0)
 sim.spatial_autonomy=true
 var a=sim.people[0]
 var v=sim.villages[a.clan]
 v.tech=2
 var wood=float(v.wood)
 sim.begin_task(a,{"kind":"craft","target":-1,"duration":4.0,"reason":"test"})
 if not sim.complete_task(a) or a.tool!=100 or absf(float(v.wood)-wood+4)>.01:return false
 var amount=float(v.food)
 sim.begin_task(a,{"kind":"farm","target":-1,"duration":4.0,"reason":"test"})
 if not sim.complete_task(a) or v.food<=amount or a.tool>=100:return false
 start_hazard("fire",houses[0][0].node.position,12.0)
 if hazards.size()!=1 or hazard_nodes.is_empty():return false
 var before=destroyed_total
 for pulse in range(3):update_hazards(2.1)
 if destroyed_total<=before:return false
 print("INTEGRATED_TEST craft=true tool_wear=true fire=true")
 sim.spatial_autonomy=false
 return true

func test_live_world()->bool:
 new_world(47,0)
 sim.spatial_autonomy=true
 var initial=sim.people.size()
 var days=0
 for frame in range(1200):
  if nav_dirty:
   rebuild_navigation()
   services_dirty=true
  if services_dirty:rebuild_services()
  for a in sim.people.duplicate():
   if actors.has(a.id):advance_actor_task(a,actors[a.id],.25)
  if not sim.changes.is_empty():apply_changes()
  if frame%34==33:
   step_day()
   days+=1
   spatial_society()
  if sim.people.is_empty():break
 var work=completed_visible
 var living=sim.people.size()
 print("LIVE_WORLD_TEST days=",days," initial=",initial," living=",living," tasks=",work," houses=",houses[0].size()+houses[1].size()," food=",sim.villages[0].food+sim.villages[1].food)
 sim.spatial_autonomy=false
 return days>=30 and living>0 and work>100

func test_exchange_and_inventory()->bool:
 new_world(47,0)
 sim.spatial_autonomy=true
 var a=sim.people[0]
 var b=sim.people[1]
 var previous=a.dialogue.size()
 sim.procedural_exchange(a,b)
 if a.dialogue.size()!=previous+2 or b.get("last_speech","")=="" :return false
 var r=actors[a.id]
 a.task="farm"
 a.cargo="Cibo"
 a.delivery=true
 cancel_task(a,r)
 if a.held_goods!="Cibo" or a.delivery:return false
 var sample=Sim.new()
 if not sample.import_state(JSON.parse_string(JSON.stringify(sim.export_state()))):return false
 if sample.find(int(a.id)).held_goods!="Cibo":return false
 print("EXCHANGE_INVENTORY_TEST dialogue=true retained_cargo=true saved=true")
 sim.spatial_autonomy=false
 return true

func test_behavior_brain()->bool:
 var sample=Sim.new()
 sample.start(47,0)
 sample.spatial_autonomy=true
 var a=sample.people[0]
 a.hunger=96.0
 a.fatigue=10.0
 a.health=100.0
 if sample.choose_task(a,{"eat":1.0,"farm":2.0,"sleep":1.0}).kind!="eat":return false
 sample.learn_action(a,"farm",8.0)
 sample.learn_action(a,"gather",-8.0)
 if float(a.action_values.farm)<=0 or float(a.action_values.gather)>=0:return false
 var v=sample.villages[a.clan]
 v.wood=0.0
 v.houses=0
 a.hunger=0.0
 a.fatigue=0.0
 a.boredom=0.0
 a.stress=0.0
 a.social_need=0.0
 var plan=sample.choose_task(a,{"gather":1.0,"house":1.0})
 if plan.kind!="gather" or a.plan_goal!="house":return false
 v.wood=30.0
 if sample.choose_task(a,{"gather":1.0,"house":1.0}).kind!="house":return false
 var copy=Sim.new()
 if not copy.import_state(JSON.parse_string(JSON.stringify(sample.export_state()))):return false
 if copy.people[0].plan_goal!="house" or float(copy.people[0].action_values.farm)<=0:return false
 sample.day=14
 v.food=0
 sample.storyteller()
 if v.get("council_focus","")!="CIBO":return false
 print("BRAIN_TEST priorities=true learning=true prerequisite_plan=true persistence=true storyteller=true")
 return true


func rebuild_regional_bridges():
 if not is_instance_valid(regional_root):return
 for child in regional_root.get_children():
  regional_root.remove_child(child)
  child.queue_free()
 if not expanded_world:return
 for link in ([] if ocean.enabled else REGION_BRIDGES):
  var a=Vector3(link[0].x,SEA+.85,link[0].y)
  var b=Vector3(link[1].x,SEA+.85,link[1].y)
  var count=ceili(a.distance_to(b))
  var side=(b-a).normalized().cross(Vector3.UP)*1.1
  for j in range(count):
   var p=a.lerp(b,float(j)/count)
   var q=a.lerp(b,float(j+1)/count)
   if height_at((p.x+q.x)*.5,(p.z+q.z)*.5)>SEA+.65:continue
   route_beam(regional_root,p-Vector3.UP*.08,q-Vector3.UP*.08,2.5,.16,Color("a58a61"))
   for sign_value in [-1,1]:
    var edge=p+side*sign_value
    block(regional_root,Color("766249"),edge+Vector3.UP*.34,Vector3(.10,.68,.10))
    route_beam(regional_root,edge+Vector3.UP*.47,q+side*sign_value+Vector3.UP*.47,.08,.10,Color("9b815b"))
 for i in range(1,REGION_POINTS.size()):
  var pt:Vector2=REGION_POINTS[i]
  var q=ground(pt.x,pt.y)
  var signpost=Label3D.new()
  regional_root.add_child(signpost)
  signpost.position=q+Vector3.UP*2.2
  signpost.text=REGION_NAMES[i]
  signpost.font_size=30
  signpost.pixel_size=.011
  signpost.outline_size=5
  signpost.billboard=BaseMaterial3D.BILLBOARD_ENABLED

func observe_region(i:int):
 if i>0 and not expanded_world:
  open_dialog("REGIONI","Questa partita usa la mappa classica. Seleziona Arcipelago alla creazione di un nuovo universo.")
  return
 set_tour(false)
 following=false
 var q:Vector2=REGION_POINTS[i]
 focus=ground(q.x,q.y)
 distance=37 if i==0 else 20
 pitch=.84
 update_camera()

func show_regions():
 var lines=["Isola delle origini · territorio iniziale dei due popoli."]
 if expanded_world:
  for i in range(1,REGION_POINTS.size()):
   var discovered=discovery_sites.any(func(row):return str(row.name)==REGION_NAMES[i] and bool(row.found))
   lines.append(REGION_NAMES[i]+" · "+("scoperta dagli abitanti" if discovered else "ancora da esplorare"))
  if ocean.enabled:
   lines.append("Le terre sono separate: spedizioni e merci viaggiano via nave. Le colonie amministrano risorse e popolazione proprie.")
   for colony in ocean.colonies:lines.append("%s: %d abitanti · %d case · prosperità %d%%"%[colony.name,int(colony.population),int(colony.houses),int(colony.prosperity)])
  else:lines.append("I ponti collegano le isole: gli esploratori possono raggiungerle senza teletrasporto.")
 else:lines.append("Mappa classica. Le isole aggiuntive sono disponibili creando un nuovo arcipelago.")
 open_dialog("ATLANTE DELLE REGIONI","\n\n".join(lines))

func test_culture_and_regions()->bool:
 var t=Sim.new()
 t.start(47,0)
 t.spatial_autonomy=true
 var a=t.people[0]
 t.begin_task(a,{"kind":"research","target":-1,"duration":1.0,"reason":"test"})
 if not t.complete_task(a) or absf(float(t.villages[0].culture.treasury)-.25)>.001:return false
 t.day=7
 t.villages[0].food=0
 t.advance_culture()
 if t.villages[0].culture.policy!="Sostentamento" or int(t.villages[0].culture.leader)<0:return false
 t.day=30
 t.villages[0].food=200
 t.villages[0].culture.treasury=50
 t.advance_culture()
 if int(t.villages[0].culture.festivals)!=1 or int(t.villages[0].culture.heritage)!=3 or float(t.villages[0].culture.treasury)>=50:return false
 var clone=Sim.new()
 if not clone.import_state(JSON.parse_string(JSON.stringify(t.export_state()))):return false
 if int(clone.villages[0].culture.festivals)!=1:return false
 var legacy=JSON.parse_string(JSON.stringify(t.export_state()))
 for v in legacy.villages:v.erase("culture")
 var old_copy=Sim.new()
 if not old_copy.import_state(legacy) or old_copy.villages[0].culture.policy!="Comunità":return false
 var village=t.villages[0]
 village.culture.policy="Solidarietà"
 village.culture.next_vote=100
 village.culture.next_festival=100
 village.food=100.0
 village.culture.treasury=10.0
 a.hunger=80.0
 a.coins=0.0
 var before_relief=int(village.culture.relief)
 t.advance_culture()
 if int(village.culture.relief)<=before_relief or a.hunger>=80 or float(village.food)>=100 or float(village.culture.treasury)>=10:return false
 new_world(47,0,true)
 for i in range(1,REGION_POINTS.size()):
  var pt:Vector2=REGION_POINTS[i]
  if height_at(pt.x,pt.y)<SEA+.3:return false
  var origin=near_cell(centers[i-1])
  var target=near_cell(ground(pt.x,pt.y))
  if not nav_grid.region.has_point(origin) or not nav_grid.region.has_point(target):return false
  if nav_grid.get_id_path(origin,target).is_empty():return false
 if discovery_sites.filter(func(row):return str(row.name) in REGION_NAMES.slice(1)).size()!=2:return false
 var explorer=sim.people[0]
 var island:Vector2=REGION_POINTS[1]
 discover_near(explorer,ground(island.x,island.y))
 if not discovery_sites.any(func(row):return row.name==REGION_NAMES[1] and row.found):return false
 var region_path="user://genesis47_region_test.json"
 if not save_path(region_path,false):return false
 new_world(47,0,false)
 var restored=load_path(region_path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(region_path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(region_path+ext))
 if not restored or not expanded_world or not discovery_sites.any(func(row):return row.name==REGION_NAMES[1] and row.found):return false
 var location=ground(island.x,island.y)
 sim.weather_name="Sereno"
 start_hazard("fire",location,10.0)
 update_hazards(1.0)
 var dry_life=float(hazards[0].life)
 hazards.clear()
 sim.weather_name="Pioggia"
 start_hazard("fire",location,10.0)
 update_hazards(1.0)
 if float(hazards[0].life)>=dry_life:return false
 hazards.clear()
 start_hazard("tornado",Vector3.ZERO,10.0)
 update_hazards(1.0)
 var movement=Vector2(float(hazards[0].x),float(hazards[0].z))
 if movement.length()<.1:return false
 hazards.clear()
 rebuild_hazards()
 print("CULTURE_REGION_TEST treasury=true votes=true relief=true persistence=true legacy_save=true connected_islands=2 region_save=true weather=true")
 return true


func request_expedition(clan:int):
 if ocean.recruit(clan,clan+1):
  apply_changes()
  ocean.sync_visuals()
  refresh()
  notify_event("SPEDIZIONE","Due abitanti partono per fondare una colonia.")
 else:notify_event("SPEDIZIONE NON DISPONIBILE","Servono tecnologia Utensili, 10 abitanti, 35 cibo, 24 legna, 20 monete e due adulti liberi; la regione deve essere libera.")

func test_ocean_systems()->bool:
 new_world(47,0,true,true)
 var a=sim.people[0]
 var rig:Dictionary=actors[a.id].skeletal
 if rig.skeleton.get_bone_count()!=22:return false
 CreatureRig.drive(actors[a.id],a,true,true,.1)
 var arm_index=int(rig.arm_ids[0][1])
 if absf(rig.skeleton.get_bone_pose_rotation(arm_index).x)<.01:return false
 var island:Vector2=REGION_POINTS[1]
 var start=near_cell(centers[0])
 var finish=near_cell(ground(island.x,island.y))
 if not nav_grid.region.has_point(start) or not nav_grid.region.has_point(finish):return false
 if not nav_grid.get_id_path(start,finish).is_empty():return false
 var v=sim.villages[0]
 v.tech=2
 v.food=100.0
 v.wood=100.0
 var people_before=sim.people.size()
 if not ocean.recruit(0,1) or sim.people.size()!=people_before-2:return false
 apply_changes()
 if actors.size()!=sim.people.size():return false
 var ship:Dictionary=ocean.voyages[0]
 var sea_route:Dictionary=ocean.route_for(ship)
 if sea_route.points.size()<2:return false
 for p in sea_route.points:
  if height_at(p.x,p.z)>SEA-.10:return false
 sim.day=int(ship.due)
 sim.weather_name="Sereno"
 ocean.daily()
 if ocean.colonies.size()!=1 or int(ocean.colonies[0].population)!=2 or not ocean.voyages.is_empty():return false
 var port_id=int(ocean.colonies[0].id)
 ocean.change(0,"stone",20.0)
 ocean.change(port_id,"cash",100.0)
 var stock=float(ocean.balance(0,"stone"))
 var funds=float(ocean.balance(port_id,"cash"))
 var seller_cash=float(ocean.balance(0,"cash"))
 if not ocean.place_order(0,port_id,"stone",4):return false
 var order:Dictionary=ocean.voyages[0]
 if absf(float(ocean.balance(0,"stone"))-(stock-float(order.amount)))>.001:return false
 if absf(float(ocean.balance(port_id,"cash"))-(funds-float(order.cost)))>.001:return false
 if float(ocean.balance(0,"cash"))!=seller_cash:return false
 var path="user://genesis47_ocean_test.json"
 if not save_path(path,false):return false
 new_world(47,0,false)
 var loaded=load_path(path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 if not loaded or not ocean.enabled or not sim.market_mode or ocean.colonies.size()!=1 or ocean.voyages.size()!=1:return false
 var pending:Dictionary=ocean.voyages[0]
 sim.day=int(pending.due)
 sim.weather_name="Sereno"
 var cargo_before=float(ocean.balance(port_id,"stone"))
 ocean.settle(pending)
 if absf(float(ocean.balance(port_id,"stone"))-cargo_before-float(pending.amount))>.001:return false
 if absf(float(ocean.balance(0,"cash"))-seller_cash-float(pending.cost))>.001:return false
 var colony_stock=float(ocean.balance(port_id,"stone"))
 var cash_after=float(ocean.balance(0,"cash"))
 if not ocean.place_order(port_id,0,"stone",1.0):return false
 var refund:Dictionary=ocean.voyages[0]
 var population=int(ocean.colonies[0].population)
 ocean.colonies[0].population=0
 ocean.settle(refund)
 ocean.colonies[0].population=population
 if absf(float(ocean.balance(port_id,"stone"))-colony_stock)>.001 or absf(float(ocean.balance(0,"cash"))-cash_after)>.001:return false
 var old_quality=quality_mode
 quality_mode=1
 debris.spawn(centers[0],1.0,"test")
 quality_mode=old_quality
 if debris.count_bodies()!=8:return false
 var fragment:RigidBody3D=debris.batches[0].bodies[0]
 if fragment.get_child_count()<2 or fragment.linear_velocity.length()<=0:return false
 debris.update(6.0,false)
 if debris.count_bodies()!=0:return false
 print("OCEAN_TEST skeleton=22 disconnected_land=true water_route=true emigration=true colony=true escrow=true save=true delivery=true refund=true rigid_bodies=true")
 return true


func show_structure(node:Node3D,site:Dictionary):
 var cover:Node3D=node.get_meta("cover")
 if not is_instance_valid(cover):return
 var health=Structure.integrity(site)
 cover.rotation.z=(1.0-health/100.0)*.09*(1 if float(site.supports[0])<float(site.supports[1]) else -1)
 cover.position.y=-(1.0-health/100.0)*.10
 for child in cover.get_children():
  if child is MeshInstance3D:
   child.transparency=0.0

func repair_structures():
 for clan in range(2):
  var village=sim.villages[clan]
  for i in range(house_sites[clan].size()):
   var site:Dictionary=house_sites[clan][i]
   var cost=Structure.repair(site,float(village.wood))
   village.wood-=cost
   if cost>0 and i<houses[clan].size():show_structure(houses[clan][i].node,site)

func flood_damage(model):
 var impacted=[]
 for clan in range(2):
  for home in houses[clan]:
   var p:Vector3=home.node.position
   var d=float(model.at(p))
   if d>.40:impacted.append([p,minf(40,d*12)])
 for row in impacted:
  disaster(row[0],"Alluvione",1.1,float(row[1]),0,0)
 for a in sim.people:
  if actors.has(a.id):
   var d=float(model.at(actors[a.id].node.position))
   if d>.4:a.health=maxf(1,float(a.health)-minf(12,d*3))

func colony_citizen_report(a:Dictionary)->String:
 return "%s\nEtà: %d · Salute: %d · Fame: %d\nUmore: %d · Stanchezza: %d\nAzione: %s · %s\nRisparmi: %.1f · Attività concluse: %d\nGenitori: %s · Partner: %d\n\n%s"%[a.name,int(a.age),int(a.health),int(a.hunger),int(a.mood),int(a.fatigue),str(ocean.life.LABELS.get(a.task,"Decide")),str(a.task_stage),float(a.coins),int(a.tasks_done),str(a.parents),int(a.partner),"\n".join(a.memories)]

func test_deep_simulation()->bool:
 new_world(47,0,true,true)
 sim.villages[0].tech=2
 sim.villages[0].food=100.0
 sim.villages[0].wood=100.0
 var first=sim.people[0]
 var rig:Dictionary=actors[first.id].skeletal
 if rig.skins.size()!=1:return false
 var mesh:MeshInstance3D=rig.skins[0]
 var arrays=mesh.mesh.surface_get_arrays(0)
 if mesh.skin==null or arrays[Mesh.ARRAY_WEIGHTS].size()<16:return false
 var weights:PackedFloat32Array=arrays[Mesh.ARRAY_WEIGHTS]
 for i in range(0,weights.size(),4):
  if absf(weights[i]+weights[i+1]+weights[i+2]+weights[i+3]-1.0)>.001:return false
 var first_id=int(first.id)
 var cash_before=float(ocean.balance(0,"cash"))
 if not ocean.finance.capitalize(0,20):return false
 if not ocean.finance.deposit(0,first_id,1):return false
 if not ocean.finance.lend(0,5):return false
 var sheet:Dictionary=ocean.finance.balance_sheet(0)
 if absf(float(sheet.assets)-float(sheet.liabilities)-float(sheet.equity))>.001:return false
 if not ocean.finance.withdraw(0,first_id,1):return false
 if absf(float(ocean.balance(0,"cash"))-cash_before+15)>.001:return false
 if not ocean.recruit(0,1):return false
 apply_changes()
 var row:Dictionary=ocean.voyages[0]
 var migrant_id=int(row.crew[0].id)
 ocean.settle(row)
 ocean.sync_visuals()
 var c:Dictionary=ocean.colonies[0]
 if c.citizens.size()!=2 or not ocean.life.actors.has(migrant_id):return false
 for i in range(240):ocean.life.tick(.25)
 if int(c.completed_tasks)<=0 or c.citizens.size()!=int(c.population):return false
 var location:Vector3=centers[0]
 hydro.inject(location,8.0)
 var mass_before=hydro.mass()
 for i in range(8):hydro.step(.20)
 if absf(hydro.mass()+hydro.drained-mass_before)>.01:return false
 if hydro.at(location)>=mass_before:return false
 var site={"x":location.x,"z":location.z}
 if Structure.stress(site,location,15.0,"Terremoto",0):return false
 if Structure.integrity(site)>=100:return false
 for i in range(5):Structure.stress(site,location,25.0,"Terremoto",0)
 if Structure.integrity(site)>=22:return false
 var path="user://genesis47_deep_test.json"
 var tasks=int(c.completed_tasks)
 if not save_path(path,false):return false
 new_world(47,0)
 var loaded=load_path(path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 if not loaded or ocean.colonies.size()!=1 or int(ocean.colonies[0].completed_tasks)!=tasks:return false
 if not ocean.life.actors.has(first_id) or hydro.mass()<=0 or ocean.finance.banks.is_empty():return false
 print("DEEP_TEST skin_weights=true colony_agents=true local_jobs=true bank_balance=true flood_mass=true structural_damage=true persistence=true")
 return true


func test_industry_and_volume()->bool:
 new_world(47,0,true,true)
 var market=ocean.industry
 var port=0
 var v=sim.villages[port]
 v.tech=5
 v.food=100.0
 v.wood=100.0
 var original_cash=float(ocean.balance(port,"cash"))
 if not market.create_company(port,"mill",30):return false
 if not market.create_company(port,"bakery",30):return false
 var mill:Dictionary=market.companies[0]
 var bakery:Dictionary=market.companies[1]
 if absf(float(ocean.balance(port,"cash"))+market.cash_total()-original_cash)>.001:return false
 var farmer=sim.find(int(mill.employees[0]))
 var wallet=float(farmer.coins)
 market.on_work(port,farmer,"farm")
 if float(mill.labor)<1 or absf(float(farmer.coins)-wallet-.8)>.001:return false
 var raw=float(ocean.balance(port,"food"))
 if not market.produce(mill):return false
 if absf(float(ocean.balance(port,"food"))-raw+3)>.001 or float(mill.stock.get("flour",0))!=2:return false
 var total_cash=float(ocean.balance(port,"cash"))+market.cash_total()
 if not market.make_contract(int(mill.id),int(bakery.id),"flour",2):return false
 if absf(float(ocean.balance(port,"cash"))+market.cash_total()-total_cash)>.001:return false
 market.settle_contract(market.contracts[0])
 if float(bakery.stock.get("flour",0))!=2:return false
 bakery.labor=1.0
 if not market.produce(bakery) or float(bakery.stock.get("bread",0))!=3:return false
 if not market.sell(bakery,"bread",2):return false
 if absf(float(ocean.balance(port,"cash"))+market.cash_total()-total_cash)>.001:return false
 if ocean.balance(port,"bread")!=2:return false
 if not ocean.finance.capitalize(port,10):return false
 if not ocean.finance.lend_company(port,int(bakery.id),4):return false
 var bank_sheet:Dictionary=ocean.finance.balance_sheet(port)
 if absf(float(bank_sheet.assets)-float(bank_sheet.liabilities)-float(bank_sheet.equity))>.001:return false
 var loan:Dictionary=ocean.finance.bank(port).company_loans[0]
 ocean.finance.repay_company(port,loan,false)
 if not ocean.finance.bank(port).company_loans.is_empty():return false
 var p:Vector3=centers[0]+Vector3.UP
 if fluid_volume.emit(p,48,Vector3(1,2,0))!=48:return false
 var initial_mass=fluid_volume.mass()
 var first_position:Vector3=fluid_volume.particles[0].p
 for i in range(20):fluid_volume.step(.025)
 if fluid_volume.particles.is_empty() or first_position.distance_to(fluid_volume.particles[0].p)<.1:return false
 if absf(fluid_volume.mass()+fluid_volume.transferred-initial_mass)>.001:return false
 var rig:Dictionary=actors[farmer.id].skeletal
 if rig.axial.size()!=5 or MotionLibrary.CLIPS.size()<10:return false
 for mesh in rig.skins:
  var weights:PackedFloat32Array=mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_WEIGHTS]
  if weights.is_empty():return false
  for i in range(0,weights.size(),4):
   if absf(weights[i]+weights[i+1]+weights[i+2]+weights[i+3]-1.0)>.001:return false
 var path="user://genesis47_industry_test.json"
 if not save_path(path,false):return false
 new_world(47,0)
 var ok=load_path(path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 if not ok or ocean.industry.companies.size()!=2 or ocean.industry.batches!=2:return false
 if absf(fluid_volume.mass()+fluid_volume.transferred-initial_mass)>.001:return false
 var before=float(hydro.mass())
 for a in fluid_volume.particles:a.age=13.0
 fluid_volume.step(.025)
 if not fluid_volume.particles.is_empty() or absf(hydro.mass()-before-initial_mass)>.001:return false
 print("INDUSTRY_VOLUME_TEST companies=true recipes=true wages=true contracts=true cash_conservation=true skin_weights=true mocap=true 3d_particles=true transfer=true persistence=true")
 return true


func test_continuous_systems()->bool:
 new_world(47,0,true,true)
 var a=sim.people[0]
 var rig:Dictionary=actors[a.id].skeletal
 if rig.skins.size()!=1:return false
 var mesh:MeshInstance3D=rig.skins[0]
 if mesh.mesh.get_surface_count()!=1:return false
 var arrays=mesh.mesh.surface_get_arrays(0)
 var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
 var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 if vertices.size()<500 or indices.size()<1500:return false
 var adj={}
 for i in range(0,indices.size(),3):
  for j in range(3):
   var u=indices[i+j]
   var v=indices[i+(j+1)%3]
   if not adj.has(u):adj[u]=[]
   if not adj.has(v):adj[v]=[]
   adj[u].append(v)
   adj[v].append(u)
 var seen={}
 seen[indices[0]]=true
 var todo=[indices[0]]
 while not todo.is_empty():
  var id=int(todo.pop_back())
  for other in adj.get(id,[]):
   if not seen.has(other):seen[other]=true;todo.append(other)
 if seen.size()!=vertices.size():return false
 for task in Sim.TASK_LABELS:
  if not MotionLibrary.TASKS.has(task) or not MotionLibrary.CLIPS.has(MotionLibrary.TASKS[task]):return false
 var market=ocean.industry
 sim.villages[0].food=100.0
 sim.villages[0].wood=100.0
 if not market.create_company(0,"mill",40.0):return false
 var firm:Dictionary=market.companies[0]
 var worker=sim.find(int(firm.employees[0]))
 worker.hunger=0.0
 worker.fatigue=0.0
 worker.health=100.0
 var node:Node3D=actors[worker.id].node
 var cash_before=float(ocean.balance(0,"cash"))+market.cash_total()+float(worker.coins)
 var food_before=float(ocean.balance(0,"food"))
 for i in range(400):
  market.advance(0,worker,node,.25)
  if market.delivered_units>=1:break
 if market.produced_units<1 or market.delivered_units<1:return false
 if absf(float(ocean.balance(0,"food"))-food_before+1.5)>.001:return false
 if absf(float(ocean.balance(0,"cash"))+market.cash_total()+float(worker.coins)-cash_before)>.001:return false
 if not market.create_company(0,"bakery",24.0):return false
 var buyer:Dictionary=market.companies[1]
 var before_delivery=float(market.delivered_units)
 for i in range(400):
  market.advance(0,worker,node,.25)
  if market.delivered_units>before_delivery:break
 if float(buyer.stock.get("flour",0))<1:return false
 var wet_cell=-1
 for i in range(ocean_dynamics.wet.size()):
  if ocean_dynamics.wet[i] and ocean_dynamics.bed[i]>2:
   wet_cell=i
   break
 if wet_cell<0:return false
 var pos=Vector3((wet_cell%OceanDynamics.N-26)*OceanDynamics.CELL,SEA,(int(wet_cell/OceanDynamics.N)-26)*OceanDynamics.CELL)
 ocean_dynamics.disturb(pos,.5)
 var volume=ocean_dynamics.displacement()
 for i in range(6):ocean_dynamics.step(OceanDynamics.DT)
 if absf(ocean_dynamics.displacement()-volume)>.002:return false
 if ocean_dynamics.velocity.size()!=OceanDynamics.N*OceanDynamics.N*OceanDynamics.L:return false
 var moving_layers=0
 for vv in ocean_dynamics.velocity:
  if vv.length_squared()>.000001:moving_layers+=1
 if moving_layers<OceanDynamics.L:return false
 var path="user://genesis47_continuous_test.json"
 if not save_path(path,false):return false
 new_world(47,0)
 var ok=load_path(path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 if not ok or ocean.industry.delivered_units<1 or absf(ocean_dynamics.displacement()-volume)>.003:return false
 print("CONTINUOUS_TEST connected_mesh=true vertices=",vertices.size()," physical_production=true delivery=true cash_conserved=true ocean_layers=",OceanDynamics.L," displacement_conserved=true persistence=true")
 return true


func run_quality_assurance():
 autosave_enabled=false
 var suite=QualityAssurance.new()
 var ok=suite.run(self)
 print("QA_SUITE ","PASS" if ok else "FAIL")
 get_tree().quit(0 if ok else 1)

func capture_pose_gallery()->int:
 speed=0
 hud.hide()
 if sim.people.is_empty():return ERR_DOES_NOT_EXIST
 var a=sim.people[0]
 var r:Dictionary=actors[a.id]
 var actor:Node3D=r.node
 actor.scale=Vector3.ONE
 actor.rotation=Vector3.ZERO
 var center=actor.position+Vector3.UP*.59
 for action in ["walk","farm","craft","eat","sleep","social"]:
  QualityAssurance.apply_pose(r,a,action,PI*.5)
  camera.position=center+Vector3(1.5,.45,2.15)
  camera.look_at(center,Vector3.UP)
  await get_tree().create_timer(.25).timeout
  await RenderingServer.frame_post_draw
  var img=get_viewport().get_texture().get_image()
  var result=img.save_png("res://preview-pose-"+action+".png")
  if result!=OK:return result
 return OK

func _exit_tree():
 # The ocean owns three RefCounted modules which refer back to it.
 # Break these ownership cycles before Godot releases world resources.
 if ocean!=null:
  ocean.life.ocean=null
  ocean.life.world=null
  ocean.finance.ocean=null
  ocean.industry.ocean=null
  ocean.world=null
 if hydro!=null:hydro.world=null
 if fluid_volume!=null:fluid_volume.world=null
 if ocean_dynamics!=null:ocean_dynamics.world=null
 if debris!=null:debris.world=null
 if legend!=null:legend.world=null
 if wildlife!=null:wildlife.world=null
 if living_score!=null:living_score.world=null
 if districts!=null:districts.world=null
 if origins!=null:origins.world=null
 if cave!=null:cave.world=null
 if rivers!=null:rivers.world=null
 if legacy!=null:legacy.world=null


func show_legend():
 right_panel.show()
 inspector_tabs.current_tab=5
 refresh()

func follow_story():
 var person={}
 for row in legend.entries:
  var a=sim.find(int(row.person))
  if not a.is_empty() and actors.has(a.id):person=a;break
 if person.is_empty() and not sim.people.is_empty():person=sim.people[0]
 if not person.is_empty():follow_person(int(person.id))

func show_story_locations():
 var dlg=AcceptDialog.new()
 hud.add_child(dlg)
 dlg.title="LUOGHI DELLA MEMORIA"
 var box=VBoxContainer.new()
 dlg.add_child(box)
 for entry in legend.entries.slice(0,8):
  var x=float(entry.x)
  var z=float(entry.z)
  button(box,"G%03d · %s · %s"%[int(entry.day),str(entry.kind),str(entry.caption).substr(0,42)],func():
   following=false
   set_tour(false)
   focus=ground(x,z)
   distance=14
   pitch=.75
   update_camera()
   dlg.hide())
 if legend.entries.is_empty():text_label(box,"La storia non è ancora stata scritta.",15)
 dlg.confirmed.connect(dlg.queue_free)
 dlg.canceled.connect(dlg.queue_free)
 dlg.popup_centered(Vector2i(540,320))

func show_biomes():
 var lines=["BIOMI DEL MONDO","Sei regioni climatiche con flora e colori distinti nella mappa giocabile."]
 for label in Art.BIOMES:lines.append("• "+label)
 lines.append("")
 lines.append(wildlife.report())
 if vast_world:
  lines.append(rivers.report())
  lines.append(cave.report()+" · premi C")
 lines.append(districts.report())
 lines.append(legacy.report())
 open_dialog("ATLANTE NATURALE","\n".join(lines))

func test_player_experience()->bool:
 new_world(47,0,true,true)
 var a=sim.people[0]
 legend.meet(int(a.id),false)
 legend.meet(int(a.id),true)
 if legend.journey!=2:return false
 legend.miracle("Provviste",0,[a],centers[0])
 if legend.journey!=3 or float(legend.worship[0].love)<=55:return false
 legend.miracle("Pace",0,[a],centers[0])
 legend.miracle("Meteorite",0,[a],centers[0])
 if float(legend.worship[0].fear)<=0:return false
 legend.discovered(a,"test",centers[0])
 if legend.journey!=4:return false
 sim.villages[0].era=1
 sim.villages[0].wood=100
 legend.worship[0].love=80.0
 legend.daily()
 if not legend.worship[0].temple or legend_root.get_child_count()<1:return false
 a.age=20
 a.hunger=0
 a.fatigue=0
 a.health=100
 a.faith=80
 sim.day+=posmod(-sim.day-int(a.id),14)
 for i in range(360 if vast_world else 180):
  legend.ritual_advance(a,actors[a.id].node,.25)
  if int(legend.worship[0].visits)>0:break
 if int(legend.worship[0].visits)<1:return false
 if wildlife.life.is_empty():return false
 var fauna_count=wildlife.life.size()
 var b=sim.people[1]
 var victim_id=int(b.id)
 sim.die(b,"test")
 legend.death(victim_id,actors[victim_id].node.position)
 apply_changes()
 if legend.monuments.is_empty():return false
 var path="user://genesis47_experience_test.json"
 if not save_path(path,false):return false
 new_world(47,0)
 var ok=load_path(path)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 if not ok or legend.journey!=4 or legend.monuments.size()!=1 or not legend.worship[0].temple or wildlife.life.size()!=fauna_count:return false
 print("EXPERIENCE_TEST journey=true witnesses=true faith=true shrine=true pilgrimage=true memorial=true wildlife=true persistence=true")
 return true


func test_frontier_origins()->bool:
 new_world(47,0,true,true,true)
 if nav_grid.region.size.x!=189:return false
 var point:Vector2=Frontier.POINTS[0]
 var destination=near_cell(ground(point.x,point.y))
 var start=near_cell(centers[0])
 if not nav_grid.region.has_point(destination) or nav_grid.get_id_path(start,destination).is_empty():return false
 sim.villages[0].era=4
 sim.villages[0].houses=9
 districts.sync()
 if districts.districts.size()<3:return false
 new_world(47,0,false,false,false,true)
 if not origins.active or not sim.people.is_empty():return false
 origins.lineages=[]
 for clan in range(2):
  for i in range(3):origins.lineages.append({"clan":clan,"gen":6,"age":3,"energy":90.0,"genes":[.8,.55,.5,.6]})
 origins.daily()
 if origins.active or sim.people.size()<4:return false
 if not legend.genealogy(int(sim.people[0].id)).contains(str(sim.people[0].name)):return false
 print("FRONTIER_TEST extended_path=true districts=true origins=true genealogy=true")
 return true


func test_world_depth()->bool:
 new_world(47,0,true,true,true)
 if sim.population_limit!=640 or sim.housing_limit!=100:return false
 sim.villages[0].era=4
 sim.villages[0].wood=200
 sim.villages[0].houses=12
 districts.sync()
 rebuild_services()
 var stations=0
 for service in services.values():
  if service.has("district"):stations+=1
 if stations<1:return false
 if rivers.streams.size()!=2:return false
 for i in range(80):rivers.step(.2)
 var mass_error=absf(rivers.mass()+rivers.discharged-rivers.supplied-rivers.initial)
 if mass_error>.01 or rivers.discharged<=0:return false
 var kinds=wildlife.species_counts()
 if kinds.count(0)>0:return false
 if not cave.enter(true):return false
 # Search the actual maze and walk each tile with collision checks.
 var start=Vector2i(1,1)
 var finish=Vector2i(13,9)
 var queue=[start]
 var came={}
 came[start]=start
 while not queue.is_empty():
  var p:Vector2i=queue.pop_front()
  if p==finish:break
  for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   var q=p+delta
   if not came.has(q) and cave.tile(Vector2(q)):
    came[q]=p
    queue.append(q)
 if not came.has(finish):return false
 var path=[]
 var current=finish
 while current!=start:
  path.push_front(current)
  current=came[current]
 for point in path:
  var direction=(Vector2(point)-cave.position).normalized()
  cave.move(direction,1.0/2.2)
 if not cave.found:return false
 cave.leave()
 var file="user://genesis47_depth_test.json"
 if not save_path(file,false):return false
 new_world(47,0)
 var ok=load_path(file)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(file+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(file+ext))
 if not ok or not cave.found or sim.population_limit!=640 or rivers.streams.size()!=2:return false
 var large=Sim.new()
 large.start(47,0)
 large.population_limit=640
 large.housing_limit=100
 while large.people.size()<200:
  if large.birth(large.people.size()%2,[]).is_empty():return false
 var restored=Sim.new()
 if not restored.import_state(JSON.parse_string(JSON.stringify(large.export_state()))) or restored.people.size()!=200:return false
 if absf(rivers.mass()+rivers.discharged-rivers.supplied-rivers.initial)>.01:return false
 print("WORLD_DEPTH_TEST cave=true river_mass_error=",mass_error," district_stations=",stations," species=4 population_capacity=640 population_roundtrip=200 persistence=true")
 return true


# Two short, interruptible personal-care phases following an actual sleep.
# These are timed gestures at the home, not a fake log of completed chores.
func morning_ritual(a:Dictionary,r:Dictionary,dt:float)->bool:
 var stage=int(a.get("morning_stage",0))
 if stage<=0:return false
 if a.hunger>75 or a.fatigue>85 or a.health<45:
  a["morning_stage"]=0
  r.erase("morning_left")
  return false
 if not r.has("morning_left"):r["morning_left"]=.85 if stage==1 else .65
 a["industry_action"]="heal" if stage==1 else "craft"
 a.task_stage="In corso"
 a.activity="Si lava" if stage==1 else "Si veste"
 r.morning_left=float(r.morning_left)-dt
 if float(r.morning_left)<=0:
  r.erase("morning_left")
  if stage==1:
   a.health=minf(100,float(a.health)+.4)
   a["morning_stage"]=2
  else:
   a.mood=minf(100,float(a.mood)+1)
   a["morning_stage"]=0
   a["morning_completed"]=int(a.get("morning_completed",0))+1
 return true

func test_living_legacy()->bool:
 new_world(47,0,true,true,true)
 var a=sim.people[0]
 var clan=int(a.clan)
 sim.villages[clan].wood=100
 var before=float(sim.villages[clan].wood)
 if not legacy.invent(clan,a,2):return false
 if absf(float(sim.villages[clan].wood)-before+16)>.001 or float(legacy.societies[clan].resistance)<=0:return false
 if legacy.invent(clan,a,2):return false
 legacy.elect(clan,"Repubblica","Test elezione")
 if legacy.societies[clan].leader<0:return false
 for citizen in sim.people:
  if int(citizen.clan)==clan:
   citizen.age=25
   citizen.faith=10
   citizen["dissident"]=true
   citizen.mood=0
   citizen.hunger=100
   citizen.stress=100
 legend.worship[clan].temple=true
 legacy.societies[clan].opposition=95.0
 legacy.daily()
 if not legacy.societies[clan].ban or legend.worship[clan].temple:return false
 if int(legacy.societies[clan].revolutions)<1:return false
 if legacy.sites.size()!=4:return false
 var site:Dictionary=legacy.sites[0]
 legacy.discover(a,ground(float(site.x),float(site.z)))
 if not site.found:return false
 a.hunger=0
 a.fatigue=0
 a.health=100
 a["morning_stage"]=1
 var r:Dictionary=actors[a.id]
 for i in range(10):morning_ritual(a,r,.25)
 if int(a.get("morning_completed",0))!=1:return false
 var count=legacy.archive.size()
 var file="user://genesis47_legacy_test.json"
 if not save_path(file,false):return false
 new_world(47,0)
 var ok=load_path(file)
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(file+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(file+ext))
 if not ok or legacy.archive.size()!=count or not legacy.societies[clan].ban or not legacy.sites[0].found:return false
 print("LEGACY_TEST invention=true election=true revolt=true worship_ban=true relic=true morning=true persistence=true")
 return true


# Original vector icon set for the power bar, no external fonts or images.
var power_icons:Dictionary={}
func power_icon(kind:String)->Texture2D:
 if power_icons.has(kind):return power_icons[kind]
 var glyph="M12 3 L21 12 L12 21 L3 12 Z M12 8 V16 M8 12 H16"
 if kind in ["Vita","Nuova specie","Resurrezione","Foresta"]:glyph="M12 21 V12 M12 14 Q1 13 4 4 Q12 3 12 14 M12 12 Q13 2 21 3 Q22 11 12 12"
 elif kind in ["Meteorite","Vulcano","Incendio","Fulmine"]:glyph="M13 2 L5 13 H11 L10 22 L20 10 H14 Z"
 elif kind in ["Tsunami","Pioggia","Lago"]:glyph="M12 3 Q20 13 20 16 Q20 22 12 22 Q4 22 4 16 Q4 13 12 3"
 elif kind in ["Guarigione","Provviste"]:glyph="M12 3 V21 M3 12 H21"
 elif kind in ["Conoscenza","Profeta","Fede"]:glyph="M12 2 L16 9 L23 12 L16 15 L12 22 L8 15 L1 12 L8 9 Z"
 elif kind in ["Montagna","Terremoto"]:glyph="M2 20 L10 5 L14 12 L17 7 L22 20 Z"
 elif kind=="Osserva":glyph="M2 12 Q12 0 22 12 Q12 24 2 12 M12 8 A4 4 0 1 0 12 16 A4 4 0 1 0 12 8"
 var svg='<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="'+glyph+'" fill="none" stroke="#e8ce9e" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
 var img=Image.new()
 if img.load_svg_from_string(svg)!=OK:return null
 var texture=ImageTexture.create_from_image(img)
 power_icons[kind]=texture
 return texture

func show_title_screen():
 speed=0
 hud.hide()
 var layer=CanvasLayer.new()
 layer.layer=8
 add_child(layer)
 title_intro=Control.new()
 layer.add_child(title_intro)
 title_intro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var shade=ColorRect.new()
 title_intro.add_child(shade)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.color=Color(.025,.055,.065,.63)
 shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var box=VBoxContainer.new()
 title_intro.add_child(box)
 box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 box.position=Vector2(70,190)
 box.custom_minimum_size=Vector2(650,430)
 box.add_theme_constant_override("separation",18)
 var mark=TextureRect.new()
 mark.texture=power_icon("Fede")
 mark.custom_minimum_size=Vector2(78,78)
 mark.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 mark.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 box.add_child(mark)
 var brand=Label.new()
 box.add_child(brand)
 brand.text="GENESIS 47"
 brand.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 brand.add_theme_font_size_override("font_size",70)
 brand.modulate=Color("f1d6a3")
 var tagline=Label.new()
 box.add_child(tagline)
 tagline.text="EREDITÀ VIVENTE\nLa vita ricorda. Il mondo sceglie."
 tagline.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 tagline.add_theme_font_size_override("font_size",23)
 tagline.modulate=Color("d1dfcf")
 var launch=Button.new()
 launch.text="ENTRA NEL MONDO"
 launch.custom_minimum_size=Vector2(420,58)
 launch.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 launch.add_theme_font_size_override("font_size",21)
 box.add_child(launch)
 launch.pressed.connect(func():
  title_intro.hide()
  layer.queue_free()
  hud.show()
  open_welcome())
 var footer=Label.new()
 box.add_child(footer)
 footer.text="SIMULAZIONE EVOLUTIVA  ·  OFFLINE"
 footer.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 footer.modulate=Color("a4beb5")
 box.modulate.a=0
 create_tween().tween_property(box,"modulate:a",1.0,1.1)
