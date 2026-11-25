extends RefCounted
# Autonomous, trainable avatar. All actions consume the world's actual energy.
var world
var root:Node3D
var body:Node3D
var arms:Array=[]
var legs:Array=[]
var state:Dictionary={}
var path:Array=[]
var route_at=0
var clock=0.0
var phase=0.0
var decision=0.0
var target=Vector3.ZERO
var action="Riposo"
func reset(w,data={}):
 world=w
 state={"active":false,"x":0.0,"z":0.0,"temperament":.65,"aid":0,"harvest":0,"strikes":0,"cooldown":0.0,"clan":0}
 for key in state.keys():
  if data.has(key):state[key]=data[key]
 path.clear()
 route_at=0
 clock=0
 decision=0
 action="Riposo"
 root=null
 arms.clear()
 legs.clear()
func export_state()->Dictionary:
 return state.duplicate(true)
func build(parent:Node3D):
 root=Node3D.new()
 parent.add_child(root)
 root.position=world.ground(float(state.x),float(state.z))
 root.visible=bool(state.active)
 body=Node3D.new()
 root.add_child(body)
 var basalt=Color("42594f")
 var moss=Color("8a9b65")
 var gold=Color("ecc982")
 var jade=Color("83d9bf")
 world.sphere(body,basalt,Vector3(0,3.55,0),Vector3(2.8,3.25,1.92))
 world.sphere(body,moss,Vector3(0,4.1,.68),Vector3(2.15,1.90,.72))
 world.sphere(body,basalt.lightened(.11),Vector3(0,5.44,.07),Vector3(2.15,1.62,1.52))
 world.sphere(body,Color("b5c6a3"),Vector3(0,5.15,.65),Vector3(1.47,.71,.58))
 for side in [-1,1]:
  world.sphere(body,jade,Vector3(side*.39,5.55,.75),Vector3(.30,.22,.13),1.2)
  var horn=world.cone(body,gold,Vector3(side*.79,6.28,-.08),.22,1.35,.035,9)
  horn.rotation.z=-side*.40
  var shoulder=Node3D.new()
  body.add_child(shoulder)
  shoulder.position=Vector3(side*1.33,4.15,0)
  arms.append(shoulder)
  world.sphere(shoulder,basalt,Vector3(side*.31,-.45,0),Vector3(1.25,1.55,1.36))
  var elbow=Node3D.new()
  shoulder.add_child(elbow)
  elbow.position=Vector3(side*.42,-1.05,0)
  shoulder.set_meta("elbow",elbow)
  world.sphere(elbow,basalt.lightened(.08),Vector3(0,-.52,.07),Vector3(1.0,1.45,1.02))
  world.sphere(elbow,moss,Vector3(0,-1.19,.17),Vector3(1.12,.73,1.11))
  for j in range(3):world.sphere(elbow,basalt,Vector3((j-1)*.32,-1.49,.38),Vector3(.26,.45,.44))
  var hip=Node3D.new()
  body.add_child(hip)
  hip.position=Vector3(side*.68,2.30,0)
  legs.append(hip)
  world.sphere(hip,basalt,Vector3(0,-.62,0),Vector3(1.19,1.45,1.24))
  var knee=Node3D.new()
  hip.add_child(knee)
  knee.position=Vector3(0,-1.10,0)
  hip.set_meta("knee",knee)
  world.sphere(knee,basalt.lightened(.06),Vector3(0,-.50,0),Vector3(.96,1.25,1.08))
  world.sphere(knee,moss,Vector3(0,-.93,.26),Vector3(1.09,.55,1.65))
  for j in range(4):
   var plate=world.cone(body,moss,Vector3(side*.94,3.05+j*.43,-.60),.29,.65,.025,6)
   plate.rotation.z=-side*.43
 var core=world.sphere(body,jade,Vector3(0,3.85,1.12),Vector3(.62,.77,.31),1.3)
 core.set_meta("heart",true)
 for j in range(7):
  var crystal=world.cone(body,gold,Vector3(0,5.94-j*.31,-.70-j*.045),.16,.64,.025,6,.18)
  crystal.rotation.x=-.45
 var name_tag=Label3D.new()
 root.add_child(name_tag)
 name_tag.position.y=7.2
 name_tag.text="ORION · CUSTODE"
 name_tag.font_size=42
 name_tag.pixel_size=.016
 name_tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 name_tag.modulate=gold
func summon(clan:int)->bool:
 if world.origins.active or world.centers.size()!=2:return false
 if not state.active:
  if world.sim.energy<25 and not world.unlimited:return false
  if not world.unlimited:world.sim.energy-=25
  state.active=true
  state.clan=clan
  var c:Vector3=world.centers[clan]
  var p:Vector3=world.land_near(c.x+5,c.z-5)
  root.position=p
  state.x=p.x
  state.z=p.z
  root.show()
  world.legacy.record("Custode",clan,-1,"Orion si manifesta nel mondo.",p)
 else:
  state.active=false
  root.hide()
  path.clear()
  action="Riposo"
 return true
func train(kind:int):
 state.temperament=clampf(float(state.temperament)+.12*kind,0,1)
 decision=0
func choose():
 path.clear()
 route_at=0
 var best=-INF
 var best_person={}
 var clan=int(state.clan)
 var benevolent=float(state.temperament)>=.45
 var p:Vector3=root.position
 for a in world.sim.people:
  if not world.actors.has(a.id):continue
  var q:Vector3=world.actors[a.id].node.position
  var d=world.flat_dist(p,q)
  if d>44:continue
  var score=(100-float(a.health))*.8+float(a.hunger)*.35-d*.8 if benevolent else (100-float(a.faith))*.72-d*.75
  if int(a.clan)==clan:score+=12
  if score>best:best=score;best_person=a
 if not best_person.is_empty() and best>27:
  target=world.actors[best_person.id].node.position
  action="Guarigione" if benevolent else "Ammonimento"
  if benevolent and float(best_person.hunger)>70 and float(best_person.health)>60:action="Rifornimento"
 else:
  var c:Vector3=world.centers[clan]
  var angle=float(world.sim.day%9)*TAU/9
  target=world.land_near(c.x+cos(angle)*7,c.z+sin(angle)*7)
  action="Vigila"
 var start:Vector2i=world.near_cell(p)
 var finish:Vector2i=world.near_cell(target)
 if world.nav_grid.region.has_point(start) and world.nav_grid.region.has_point(finish):
  for cell in world.nav_grid.get_id_path(start,finish):
   path.append(Vector3(cell.x,world.walking_height(cell.x,cell.y),cell.y))
 if path.size()>0:target=path.back()
 else:action="Vigila";target=p
func act()->bool:
 if float(state.cooldown)>0 or (world.sim.energy<8 and not world.unlimited):return false
 var p:Vector3=root.position
 var near=[]
 for a in world.sim.people:
  if world.actors.has(a.id) and world.flat_dist(p,world.actors[a.id].node.position)<5:near.append(a)
 if near.is_empty() or action=="Vigila":return false
 var changed=0
 var clan=int(state.clan)
 match action:
  "Guarigione":
   for a in near:
    if float(a.health)>=96 and int(a.sick)==0:continue
    a.health=minf(100,float(a.health)+25)
    a.sick=maxi(0,int(a.sick)-2)
    a.mood=minf(100,float(a.mood)+6)
    world.sim.adjust_trust(a,3)
    changed+=1
   if changed>0:state.aid=int(state.aid)+changed
  "Rifornimento":
   for a in near:
    if float(a.hunger)<65:continue
    a.hunger=maxf(0,float(a.hunger)-25)
    changed+=1
   if changed>0:
    world.sim.villages[clan].food=minf(850,float(world.sim.villages[clan].food)+12)
    state.harvest=int(state.harvest)+changed
  "Ammonimento":
   for a in near:
    if float(a.faith)>40:continue
    a.stress=minf(100,float(a.stress)+18)
    world.sim.adjust_trust(a,-4)
    changed+=1
   if changed>0:state.strikes=int(state.strikes)+changed
 if changed==0:return false
 if not world.unlimited:world.sim.energy-=8
 state.cooldown=8.0
 world.legacy.record("Custode",clan,-1,"Orion: "+action+" · "+str(changed)+" abitanti.",p)
 if not world.test_mode:
  world.divine_presentation.cast(p,"Fulmine" if action=="Ammonimento" else "Guarigione")
  world.play_event_sound(action=="Ammonimento")
 return true
func update(dt:float):
 if not bool(state.active) or not is_instance_valid(root) or world.origins.active:return
 state.cooldown=maxf(0,float(state.cooldown)-dt)
 decision-=dt
 if decision<=0:
  decision=4.0
  choose()
 var moving=false
 if route_at<path.size():
  var q:Vector3=path[route_at]
  var dir=q-root.position
  dir.y=0
  if dir.length()<.22:route_at+=1
  else:
   var p=root.position+dir.normalized()*minf(dt*2.9,dir.length())
   p.y=world.walking_height(p.x,p.z)
   if p.y>world.SEA+.18:
    root.position=p
    root.rotation.y=lerp_angle(root.rotation.y,atan2(dir.x,dir.z),minf(1,dt*3))
    moving=true
   else:path.clear()
 if not moving and route_at>=path.size():act()
 state.x=root.position.x
 state.z=root.position.z
 phase+=dt*(3.2 if moving else 1.25)
 body.position.y=absf(sin(phase))*.13 if moving else sin(phase)*.04
 for i in range(2):
  var cycle=phase+i*PI
  legs[i].rotation.x=sin(cycle)*.39 if moving else 0
  legs[i].get_meta("knee").rotation.x=maxf(0,-sin(cycle))*.48 if moving else .03
  arms[i].rotation.x=-sin(cycle)*.28 if moving else -.65*sin(clampf(float(state.cooldown)/8,0,1)*PI)
  arms[i].get_meta("elbow").rotation.x=-.18-absf(sin(cycle))*.18
func report()->String:
 return "ORION · "+("presente" if state.active else "assente")+"\n"+action+" · Indole benevola "+str(int(float(state.temperament)*100))+"%\nCurati: "+str(state.aid)+" · Riforniti: "+str(state.harvest)+" · Ammoniti: "+str(state.strikes)
