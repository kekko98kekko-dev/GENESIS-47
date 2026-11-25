extends RefCounted
const Rig=preload("res://scripts/creature_rig.gd")
const OceanDynamics=preload("res://scripts/ocean_dynamics.gd")
const POSES=["walk","run","farm","craft","eat","sleep","social","teach","heal","industry"]
var world
var report={}

func run(w)->bool:
 world=w
 world.new_world(47,0,true,true)
 var skin=pose_audit()
 var families=[]
 for kind in range(3):
  var selected={}
  for a in world.sim.people:
   if int(world.actors[a.id].skeletal.get("kind",0))==kind:selected=a;break
  if selected.is_empty():families.append({"ok":false,"kind":kind,"error":"missing phenotype"});continue
  var result=pose_audit(selected)
  result["kind"]=kind
  families.append(result)
 var anatomy_ok=families.size()==3 and families.all(func(row):return bool(row.ok))
 var contact=contact_audit()
 var growth=natural_growth_audit()
 print("QA_ANATOMIES families=",families.size()," ok=",anatomy_ok)
 var industry=industry_soak()
 var live=live_soak()
 var water=ocean_audit()
 var async_water=async_ocean_audit()
 var politics=legacy_soak()
 report={"version":ProjectSettings.get_setting("application/config/version"),"skin":skin,"anatomies":families,"contact":contact,"natural_growth":growth,"industry_fixture":industry,"live_world":live,"ocean":water,"async_ocean":async_water,"living_legacy":politics}
 var f=FileAccess.open("res://qa-report.json",FileAccess.WRITE)
 if f!=null:f.store_string(JSON.stringify(report,"  "));f.close()
 print("QA_REPORT ",JSON.stringify(report))
 return bool(skin.ok) and anatomy_ok and bool(contact.ok) and bool(growth.ok) and bool(industry.ok) and bool(live.ok) and bool(water.ok) and bool(async_water.ok) and bool(politics.ok) and f!=null

static func apply_pose(r:Dictionary,source:Dictionary,action:String,phase:float):
 var a=source.duplicate(true)
 a.task=action
 a.task_stage="In corso"
 a.erase("industry_action")
 a.delivery=false
 a.stress=90.0 if action=="run" else 0.0
 var moving=action in ["walk","run"]
 r.phase=phase
 r.body.rotation=Vector3.ZERO
 r.body.position=Vector3.ZERO
 for i in range(2):
  r.arms[i].rotation=Vector3(sin(phase+i*PI)*.32 if moving else -.35,0,0)
  r.legs[i].rotation=Vector3(sin(phase+i*PI+PI)*.45 if moving else .04,0,0)
 Rig.drive(r,a,moving,true,.2)
 var s:Skeleton3D=r.skeletal.skeleton
 s.force_update_all_bone_transforms()

func pose_audit(chosen:Dictionary={})->Dictionary:
 var a=world.sim.people[0] if chosen.is_empty() else chosen
 var r:Dictionary=world.actors[a.id]
 var s:Skeleton3D=r.skeletal.skeleton
 var mesh:MeshInstance3D=r.skeletal.skins[0]
 var arrays=mesh.mesh.surface_get_arrays(0)
 var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var ids:PackedInt32Array=arrays[Mesh.ARRAY_BONES]
 var weights:PackedFloat32Array=arrays[Mesh.ARRAY_WEIGHTS]
 var triangles:PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
 var results=[]
 var all_ok=true
 for action in POSES:
  for phase in [0.0,PI*.5,PI]:
   apply_pose(r,a,action,phase)
   var matrices=[]
   for bone in range(s.get_bone_count()):matrices.append(s.get_bone_global_pose(bone)*s.get_bone_global_rest(bone).affine_inverse())
   var deformed=PackedVector3Array()
   deformed.resize(vertices.size())
   var finite=true
   var max_extent=0.0
   for i in range(vertices.size()):
    var p=Vector3.ZERO
    for j in range(4):
     var k=i*4+j
     p+=(matrices[ids[k]]*vertices[i])*weights[k]
    deformed[i]=p
    if not p.is_finite():finite=false
    max_extent=maxf(max_extent,p.length())
   var ratios:Array[float]=[]
   for i in range(0,triangles.size()-2,9):
    for j in range(3):
     var u=triangles[i+j]
     var v=triangles[i+(j+1)%3]
     var rest=vertices[u].distance_to(vertices[v])
     if rest>.004:ratios.append(deformed[u].distance_to(deformed[v])/rest)
   ratios.sort()
   var p99=ratios[clampi(ceili(ratios.size()*.99)-1,0,ratios.size()-1)] if not ratios.is_empty() else INF
   var ok=finite and max_extent<3.0 and p99<4.0
   all_ok=all_ok and ok
   results.append({"action":action,"phase":phase,"finite":finite,"p99_edge_stretch":p99,"max_extent":max_extent,"ok":ok})
 print("QA_SKIN poses=",results.size()," vertices=",vertices.size()," ok=",all_ok)
 return {"ok":all_ok,"poses":results,"vertices":vertices.size(),"threshold_p99_stretch":4.0,"scope":"Numerical skin integrity, not an artistic evaluation"}

func controlled_cash()->float:
 var total=float(world.ocean.industry.cash_total())
 for port in [0,1]:total+=float(world.ocean.balance(port,"cash"))
 for a in world.sim.people:total+=float(a.coins)
 return total

func industry_soak()->Dictionary:
 world.new_world(47,0,true,true)
 var market=world.ocean.industry
 world.sim.villages[0].food=800.0
 world.sim.villages[0].wood=300.0
 world.ocean.change(0,"cash",2000.0)
 if not market.create_company(0,"mill",300.0) or not market.create_company(0,"bakery",300.0):return {"ok":false,"error":"fixture creation"}
 var workers=[]
 for firm in market.companies:workers.append(int(firm.employees[0]))
 var start_cash=controlled_cash()
 var max_error=0.0
 var errors=[]
 var interrupted=false
 var restored=false
 var simulated_days=0
 var path="user://genesis47_qa_industry.json"
 for day in range(90):
  world.sim.day+=1
  # Controlled demand fixture: consume a small quantity of finished goods.
  # No cash injection after initial capital; raw inputs are initially stocked.
  world.ocean.change(0,"bread",-2)
  world.ocean.change(0,"flour",-1)
  for frame in range(48):
   for id in workers:
    var a=world.sim.find(id)
    if a.is_empty() or not world.actors.has(id):return {"ok":false,"error":"fixture worker missing"}
    a.hunger=0.0
    a.fatigue=0.0
    a.health=100.0
    market.advance(0,a,world.actors[id].node,.25)
   if not interrupted and day>=10:
    for key in market.jobs.keys():
     if not market.jobs[key].get("cargo",{}).is_empty() or market.jobs[key].has("contract"):
      market.cancel_job(key)
      interrupted=true
      break
  var audit:Dictionary=market.audit()
  if not audit.ok:errors.append_array(audit.errors);break
  max_error=maxf(max_error,absf(controlled_cash()-start_cash))
  simulated_days+=1
  if day==44:
   if not world.save_path(path,false) or not world.load_path(path):errors.append("roundtrip");break
   market=world.ocean.industry
   restored=true
 for ext in ["",".bak",".tmp"]:
  if FileAccess.file_exists(path+ext):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))
 var ok=errors.is_empty() and simulated_days==90 and restored and interrupted and max_error<.03 and market.produced_units>=20 and market.delivered_units>=15
 print("QA_INDUSTRY_FIXTURE days=",simulated_days," units=",market.produced_units," delivered=",market.delivered_units," cash_error=",max_error," ok=",ok)
 return {"ok":ok,"days":simulated_days,"units":market.produced_units,"deliveries":market.delivered_units,"maximum_cash_error":max_error,"interruption":interrupted,"roundtrip":restored,"errors":errors,"scope":"Controlled supply and demand, real routing, no replenishment of cash after start"}

func live_soak()->Dictionary:
 world.new_world(91,0,true,true)
 world.sim.spatial_autonomy=true
 world.sim.villages[0].food=250.0
 world.sim.villages[0].wood=100.0
 world.sim.villages[0].tech=2
 world.ocean.change(0,"cash",300)
 world.ocean.industry.create_company(0,"mill",35.0)
 world.ocean.industry.create_company(0,"bakery",35.0)
 var days=0
 var errors=[]
 var start_population=world.sim.people.size()
 for frame in range(90*34):
  if world.nav_dirty:
   world.rebuild_navigation()
   world.services_dirty=true
  if world.services_dirty:world.rebuild_services()
  for a in world.sim.people.duplicate():
   if world.actors.has(a.id):world.advance_actor_task(a,world.actors[a.id],.25)
  world.ocean.life.tick(.25)
  if not world.sim.changes.is_empty():world.apply_changes()
  if frame%34==33:
   world.step_day()
   world.spatial_society()
   days+=1
   var audit:Dictionary=world.ocean.industry.audit()
   if not audit.ok:errors.append_array(audit.errors);break
 var market=world.ocean.industry
 var ok=days==90 and errors.is_empty()
 print("QA_LIVE_WORLD days=",days," population=",world.sim.people.size()," units=",market.produced_units," deliveries=",market.delivered_units," ok=",ok)
 world.sim.spatial_autonomy=false
 return {"ok":ok,"days":days,"initial_population":start_population,"final_population":world.sim.people.size(),"companies":market.companies.size(),"units":market.produced_units,"deliveries":market.delivered_units,"tasks":world.completed_visible,"errors":errors,"scope":"Autonomous live world, initial seed capital and resources only; no guarantee of uninterrupted growth"}

func ocean_audit()->Dictionary:
 world.new_world(47,0,true,true)
 var ocean=world.ocean_dynamics
 ocean.wind_enabled=false
 for i in range(3):ocean.step(OceanDynamics.DT)
 var rest:Dictionary=ocean.diagnostics()
 var rest_ok=rest.finite and absf(rest.volume)<.0001 and rest.maximum_speed<.0001
 var cell=-1
 for i in range(ocean.wet.size()):
  if ocean.wet[i] and ocean.bed[i]>2:
   cell=i
   break
 if cell<0:return {"ok":false,"error":"no wet cell"}
 var p=Vector3((cell%OceanDynamics.N-26)*OceanDynamics.CELL,world.SEA,(int(cell/OceanDynamics.N)-26)*OceanDynamics.CELL)
 ocean.disturb(p,.5)
 var initial=ocean.displacement()
 var max_error=0.0
 var steps=40
 for i in range(steps):
  ocean.step(OceanDynamics.DT)
  max_error=maxf(max_error,absf(ocean.displacement()-initial))
 var dynamics:Dictionary=ocean.diagnostics()
 # Verify land-adjacent drainage cannot disappear from the water budget.
 var before=ocean.displacement()
 ocean.absorb(world.centers[0],.125)
 var runoff_error=absf(ocean.displacement()-before-.125*OceanDynamics.CELL*OceanDynamics.CELL)
 var before_terrain=ocean.displacement()
 world.deformation.append({"x":p.x,"z":p.z,"r":1.1,"h":float(ocean.bed[cell])+1.0})
 world.terrain_revision+=1
 ocean.terrain()
 var terrain_error=absf(ocean.displacement()-before_terrain)
 var terrain_ok=not bool(ocean.wet[cell]) and terrain_error<.003
 # Uniform-depth standing-wave reference, small perturbation, no wind.
 ocean.wet.fill(1)
 ocean.bed.fill(4.0)
 ocean.eta.fill(0.0)
 ocean.velocity.fill(Vector3.ZERO)
 var k=TAU/(OceanDynamics.N*OceanDynamics.CELL)
 var amplitude=.05
 for z in range(OceanDynamics.N):
  for x in range(OceanDynamics.N):ocean.eta[ocean.idx(x,z)]=amplitude*cos(k*(x+.5)*OceanDynamics.CELL)
 var t=0.0
 for i in range(40):
  ocean.step(OceanDynamics.DT)
  t+=OceanDynamics.DT
 var coefficient=0.0
 for z in range(OceanDynamics.N):
  for x in range(OceanDynamics.N):coefficient+=float(ocean.eta[ocean.idx(x,z)])*cos(k*(x+.5)*OceanDynamics.CELL)
 coefficient*=2.0/(OceanDynamics.N*OceanDynamics.N)
 var analytic=amplitude*cos(sqrt(9.81*4.0)*k*t)
 var relative=absf(coefficient-analytic)/amplitude
 var wave_diag:Dictionary=ocean.diagnostics()
 var ok=rest_ok and dynamics.finite and dynamics.minimum_depth>=.079 and dynamics.dry_speed<.0001 and max_error<.003 and runoff_error<.003 and terrain_ok and wave_diag.finite and relative<.15
 print("QA_OCEAN rest=",rest_ok," volume_error=",max_error," runoff_error=",runoff_error," wave_relative_error=",relative," ok=",ok)
 return {"ok":ok,"rest":rest_ok,"volume_error":max_error,"runoff_error":runoff_error,"terrain_displacement_error":terrain_error,"terrain_change":terrain_ok,"steps":steps,"real_terrain":dynamics,"wave_analytic":analytic,"wave_numeric":coefficient,"wave_error_over_initial_amplitude":relative,"wave_tolerance":.15,"scope":"Short standing-wave reference and mass checks, not full CFD validation"}


func async_ocean_audit()->Dictionary:
 world.new_world(47,0,true,true)
 var ocean=world.ocean_dynamics
 ocean.wind_enabled=false
 var cell=-1
 for i in range(ocean.wet.size()):
  if ocean.wet[i] and ocean.bed[i]>2:
   cell=i
   break
 if cell<0:return {"ok":false,"error":"no wet cell"}
 var pos=Vector3((cell%OceanDynamics.N-26)*OceanDynamics.CELL,world.SEA,(int(cell/OceanDynamics.N)-26)*OceanDynamics.CELL)
 ocean.disturb(pos,.5)
 var original_eta=ocean.eta.duplicate()
 var original_velocity=ocean.velocity.duplicate()
 var initial=ocean.displacement()
 ocean.step(OceanDynamics.DT)
 var expected_eta=ocean.eta.duplicate()
 var expected_velocity=ocean.velocity.duplicate()
 ocean.eta=original_eta
 ocean.velocity=original_velocity
 ocean.queue_worker(float(world.sim.day),1)
 var accepted=ocean.collect_worker(true)
 var error=0.0
 for i in range(expected_eta.size()):error=maxf(error,absf(expected_eta[i]-ocean.eta[i]))
 for i in range(expected_velocity.size()):error=maxf(error,expected_velocity[i].distance_to(ocean.velocity[i]))
 var mass_error=absf(ocean.displacement()-initial)
 ocean.queue_worker(float(world.sim.day),1)
 ocean.disturb(pos,.25)
 var disturbed=ocean.displacement()
 var stale=ocean.collect_worker(true)
 var stale_error=absf(ocean.displacement()-disturbed)
 var ok=accepted and not stale and error<.00001 and mass_error<.003 and stale_error<.00001
 print("QA_ASYNC_OCEAN equivalence=",error," mass_error=",mass_error," stale_error=",stale_error," ok=",ok)
 return {"ok":ok,"numeric_error":error,"mass_error":mass_error,"stale_error":stale_error,"worker":ocean.performance_report()}

func legacy_soak()->Dictionary:
 world.new_world(81,0)
 var count=0
 var initial=world.sim.people.size()
 var error=""
 for i in range(120):
  world.sim.daily()
  world.apply_changes()
  world.legend.daily()
  world.legacy.daily()
  count+=1
  for clan in range(2):
   var row:Dictionary=world.legacy.societies[clan]
   var adults:Array=world.legacy.electorate(clan)
   if not adults.is_empty() and world.sim.find(int(row.leader)).is_empty():error="leader missing"
   if float(world.sim.villages[clan].wood)<-.01 or float(world.sim.villages[clan].food)<-.01:error="negative resources"
   var unique={}
   for item in row.inventions:
    if unique.has(item):error="duplicated invention"
    unique[item]=true
  if error!="":break
 var events=world.legacy.archive.size()
 var ok=error=="" and count==120 and events>0 and not world.sim.people.is_empty()
 print("QA_LEGACY days=",count," initial=",initial," population=",world.sim.people.size()," events=",events," ok=",ok)
 return {"ok":ok,"days":count,"initial_population":initial,"population":world.sim.people.size(),"historical_events":events,"error":error,"scope":"120-day aggregate civilization and political history; not a human playtest"}


func contact_audit()->Dictionary:
 var results=[]
 for kind in [1,2]:
  var chosen={}
  for a in world.sim.people:
   if int(world.actors[a.id].skeletal.kind)==kind:chosen=a;break
  if chosen.is_empty():return {"ok":false,"error":"missing anatomy"}
  var r:Dictionary=world.actors[chosen.id]
  var s:Skeleton3D=r.skeletal.skeleton
  var ids:Array=r.skeletal.extra[0]
  apply_pose(r,chosen,"walk",.8)
  var tip=s.get_bone_global_pose(int(ids[2])).origin
  var goal=tip+Vector3(.015,.045,.035)
  var before=tip.distance_to(goal)
  var after=Rig.aim_chain(s,ids,goal,.7)
  results.append({"kind":kind,"before":before,"after":after,"ok":is_finite(after) and after<before})
 var ok=results.all(func(row):return row.ok)
 print("QA_CONTACT ",JSON.stringify(results)," ok=",ok)
 return {"ok":ok,"results":results}
func natural_growth_audit()->Dictionary:
 var simulation=preload("res://scripts/sim.gd").new()
 simulation.start(47,0)
 var milestones=[]
 var last=-1
 for day in range(240):
  var era=int(simulation.villages[0].era)
  if era!=last:
   last=era
   milestones.append({"day":simulation.day,"era":era,"population":simulation.count(0),"houses":simulation.villages[0].houses})
  if era>=4:break
  simulation.daily()
 var ok=last>=4 and milestones.size()>=3 and int(milestones.back().houses)>int(milestones[0].houses)
 print("QA_NATURAL_GROWTH ",JSON.stringify(milestones)," ok=",ok)
 return {"ok":ok,"milestones":milestones,"scope":"same-seed aggregate autonomous daily simulation; no imposed era, citizens, resources or housing"}
