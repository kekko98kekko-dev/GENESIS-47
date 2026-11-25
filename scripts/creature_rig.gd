extends RefCounted
const Mocap=preload("res://scripts/mocap_walk.gd")
const Library=preload("res://scripts/mocap_library.gd")
const ContinuousSkin=preload("res://scripts/continuous_skin.gd")
# Articulated, bone-attached rigid stylized meshes, preserving the original species.
# Existing gameplay animation controls drive the pose; secondary joints add gait
# and task-specific follow-through. No imported mocap or deformable skin weights.
static func bone(s:Skeleton3D,label:String,parent:int,offset:Vector3)->int:
 var i=s.get_bone_count()
 s.add_bone(label)
 s.set_bone_parent(i,parent)
 s.set_bone_rest(i,Transform3D(Basis.IDENTITY,offset))
 return i

static func attach(s:Skeleton3D,label:String)->BoneAttachment3D:
 var n=BoneAttachment3D.new()
 s.add_child(n)
 n.bone_name=label
 return n

static func build(w,body:Node3D,skin:Color,cloth:Color,kind:int=0)->Dictionary:
 var skeleton=Skeleton3D.new()
 body.add_child(skeleton)
 var base=bone(skeleton,"Root",-1,Vector3.ZERO)
 var pelvis=bone(skeleton,"Pelvis",base,Vector3(0,.43,0))
 var spine=bone(skeleton,"Spine",pelvis,Vector3(0,.24,0))
 var chest=bone(skeleton,"Chest",spine,Vector3(0,.30,0))
 var neck=bone(skeleton,"Neck",chest,Vector3(0,.16,0))
 var head=bone(skeleton,"Head",neck,Vector3(0,.11,.025))
 var arm_ids=[]
 var leg_ids=[]
 var extremities=[]
 for side in [-1,1]:
  var suffix="L" if side<0 else "R"
  var shoulder=bone(skeleton,"Shoulder"+suffix,chest,Vector3(side*.34,.01,0))
  var elbow=bone(skeleton,"Elbow"+suffix,shoulder,Vector3(side*.04,-.22,0))
  var wrist=bone(skeleton,"Wrist"+suffix,elbow,Vector3(0,-.20,0))
  var hip=bone(skeleton,"Hip"+suffix,pelvis,Vector3(side*.18,0,0))
  var knee=bone(skeleton,"Knee"+suffix,hip,Vector3(0,-.17,0))
  var ankle=bone(skeleton,"Ankle"+suffix,knee,Vector3(0,-.15,0))
  arm_ids.append([shoulder,elbow,wrist])
  leg_ids.append([hip,knee,ankle])
  var fingers=bone(skeleton,"Fingers"+suffix,wrist,Vector3(0,-.065,0))
  var toes=bone(skeleton,"Toes"+suffix,ankle,Vector3(0,-.015,.16))
  extremities.append([wrist,fingers,ankle,toes])
 var extra=[]
 if kind==1:
  for side in [-1,1]:
   var suffix="L" if side<0 else "R"
   var joint=bone(skeleton,"SecondShoulder"+suffix,spine,Vector3(side*.25,.06,.06))
   var elbow=bone(skeleton,"SecondElbow"+suffix,joint,Vector3(side*.24,-.09,.12))
   var wrist=bone(skeleton,"SecondHand"+suffix,elbow,Vector3(side*.11,-.21,.06))
   extra.append([joint,elbow,wrist])
 elif kind==2:
  for side in [-1,1]:
   var suffix="L" if side<0 else "R"
   var joint=bone(skeleton,"RearHip"+suffix,pelvis,Vector3(side*.20,.02,-.42))
   var knee=bone(skeleton,"RearKnee"+suffix,joint,Vector3(side*.04,-.20,-.05))
   var ankle=bone(skeleton,"RearFoot"+suffix,knee,Vector3(0,-.15,0))
   extra.append([joint,knee,ankle])
  var tail=bone(skeleton,"TailRoot",pelvis,Vector3(0,.05,-.49))
  var tip=bone(skeleton,"TailTip",tail,Vector3(0,-.03,-.26))
  extra.append([tail,tip])
 var proportions=ContinuousSkin.proportions(kind)
 for i in range(skeleton.get_bone_count()):
  var rest=skeleton.get_bone_rest(i)
  rest.origin*=proportions
  skeleton.set_bone_rest(i,rest)
 skeleton.reset_bone_poses()
 var skins=[ContinuousSkin.build(w,skeleton,skin,kind)]
 var head_anchor=attach(skeleton,"Head")
 var chest_anchor=attach(skeleton,"Chest")
 return {"skeleton":skeleton,"kind":kind,"extra":extra,"arm_ids":arm_ids,"leg_ids":leg_ids,"skins":skins,"axial":[pelvis,spine,chest,neck,head],"extremities":extremities,"head_anchor":head_anchor,"chest_anchor":chest_anchor}

static func drive(r:Dictionary,a:Dictionary,moving:bool,detail:bool,dt:float):
 var rig=r.get("skeletal",{})
 if rig.is_empty():return
 var s:Skeleton3D=rig.skeleton
 if not is_instance_valid(s):return
 var blend=clampf(dt*14,0,1)
 var task=str(a.get("industry_action",a.get("task","")))
 var clip="idle"
 if moving:clip="run" if float(a.get("stress",0))>75 else ("deliver" if task=="deliver" else ("trade" if task=="trade" else ("carry" if bool(a.get("delivery",false)) else "walk")))
 elif str(a.get("task_stage",""))=="In corso" or task=="industry":clip=str(Library.TASKS.get(task,"idle"))
 var phase=float(r.phase)
 var axial:Array=rig.axial
 for j in range(axial.size()):
  var pose_vec=Library.sample(clip,phase,mini(15,12+j))*.60 if clip!="walk" else Vector3(sin(phase)*.04,cos(phase)*.06,0)
  pose(s,int(axial[j]),pose_vec,blend)
 for i in range(2):
  var cycle=float(r.phase)+i*PI
  var ar=r.arms[i].rotation
  var lr=r.legs[i].rotation
  var elbow=-.12
  var knee=.08
  var wrist=0.0
  var ankle=0.0
  if moving:
   elbow=-.18-absf(sin(cycle))*(.35 if detail else .15)
   knee=maxf(0.0,-sin(cycle))*(.65 if detail else .30)
   ankle=-knee*.40
  elif str(a.task_stage)=="In corso":
   match str(a.task):
    "eat","heal","research","teach":elbow=-.85;wrist=.18*sin(float(r.phase)*2)
    "farm","gather","craft","house","build":elbow=-.32-.30*absf(sin(float(r.phase)*4+i))
    "social","aid":elbow=-.45;wrist=.22*sin(float(r.phase)*3+i)
    "sleep":elbow=-.30;knee=.34;ankle=-.10
    "play":knee=.32+.22*absf(sin(float(r.phase)*4))
  if moving and detail and clip=="walk":
   var offset=i*6
   var sample_phase=float(r.phase)
   ar.x=lerpf(ar.x,Mocap.sample(sample_phase,offset),.75)
   elbow=lerpf(elbow,Mocap.sample(sample_phase,offset+1),.75)
   wrist=Mocap.sample(sample_phase,offset+2)
   lr.x=lerpf(lr.x,Mocap.sample(sample_phase,offset+3),.75)
   knee=lerpf(knee,clampf(Mocap.sample(sample_phase,offset+4),0,.9),.75)
   ankle=Mocap.sample(sample_phase,offset+5)
  var ai:Array=rig.arm_ids[i]
  var li:Array=rig.leg_ids[i]
  var offsets=[Vector3(ar.x,ar.y,ar.z),Vector3(elbow,0,0),Vector3(wrist,0,0),Vector3(lr.x,lr.y,lr.z),Vector3(knee,0,0),Vector3(ankle,0,0)]
  if clip!="walk" and detail:
   for j in range(6):offsets[j]+=Library.sample(clip,phase,i*6+j)*.65
  var ids=ai+li
  for j in range(6):pose(s,int(ids[j]),offsets[j],blend)
  var e:Array=rig.extremities[i]
  pose(s,int(e[1]),Vector3(-.18 if task in ["gather","craft","eat","farm","mine","build"] else -.04,0,0),blend)
  pose(s,int(e[3]),Vector3(maxf(0,sin(cycle))*.24 if moving else 0,0,0),blend)

 # Independent joints for the inherited extra limbs. The standard two hands remain usable for tools.
 var extra:Array=rig.get("extra",[])
 var kind=int(rig.get("kind",0))
 if kind>0:
  for i in range(2):
   var phase_shift=phase+i*PI+PI*.5
   var ids:Array=extra[i]
   if kind==1:
    var reach=Library.sample(clip,phase_shift,i*6).x*.70 if clip!="walk" else Mocap.sample(phase_shift,i*6)*.65
    pose(s,int(ids[0]),Vector3(reach,0,.08*sin(phase_shift)),blend)
    pose(s,int(ids[1]),Vector3(-.20-absf(reach)*.5+Library.sample(clip,phase_shift,i*6+1).x*.3,0,0),blend)
    pose(s,int(ids[2]),Vector3(.1*sin(phase_shift),0,0),blend)
   else:
    var gait=Mocap.sample(phase_shift,i*6+3)*.80 if moving else Library.sample(clip,phase_shift,i*6+3).x*.35
    pose(s,int(ids[0]),Vector3(gait,0,0),blend)
    pose(s,int(ids[1]),Vector3(maxf(0,-gait)*.9,0,0),blend)
    pose(s,int(ids[2]),Vector3(-maxf(0,-gait)*.3,0,0),blend)
  if kind==2:
   pose(s,int(extra[2][0]),Vector3(0,sin(phase)*.25,0),blend)
   pose(s,int(extra[2][1]),Vector3(0,sin(phase-.5)*.28,0),blend)

static func pose(s:Skeleton3D,i:int,euler:Vector3,weight:float):
 var desired=Quaternion.from_euler(euler)
 s.set_bone_pose_rotation(i,s.get_bone_pose_rotation(i).slerp(desired,weight).normalized())


# Continuous skin surface with normalized weights spanning both sides of each
# joint; native GPU skinning deforms the limb instead of rotating rigid pieces.
static func limb(w,s:Skeleton3D,ids:Array,origin:Vector3,first:Vector3,second:Vector3,radius:float,tint:Color)->MeshInstance3D:
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rings=16
 var sides=12
 for row in range(rings):
  for col in range(sides):
   for pair in [Vector2i(row,col),Vector2i(row+1,col),Vector2i(row,col+1),Vector2i(row,col+1),Vector2i(row+1,col),Vector2i(row+1,col+1)]:
    var t=float(pair.x)/rings
    var angle=float(pair.y)/sides*TAU
    var center=origin+first*minf(1,t*2)+second*maxf(0,t*2-1)
    var radial=Vector3(cos(angle),0,sin(angle))
    var taper=.70+.30*sin(PI*t)
    var blend1=smoothstep(.28,.70,t)
    var blend2=smoothstep(.76,1.0,t)*.65
    var weight0=(1.0-blend1)*(1.0-blend2)
    var weight1=blend1*(1.0-blend2)
    st.set_bones(PackedInt32Array([int(ids[0]),int(ids[1]),int(ids[2]),0]))
    st.set_weights(PackedFloat32Array([weight0,weight1,blend2,0.0]))
    st.set_normal(radial)
    st.set_uv(Vector2(float(pair.y)/sides,t))
    st.add_vertex(center+radial*radius*taper)
 var mesh=st.commit()
 var node=MeshInstance3D.new()
 s.add_child(node)
 node.mesh=mesh
 node.skeleton=NodePath("..")
 node.skin=s.create_skin_from_rest_transforms()
 node.material_override=w.material(tint)
 return node

static func weighted_ellipsoid(w,s:Skeleton3D,ids:Array,center:Vector3,radius:Vector3,tint:Color,low:float,high:float,axis:int=1)->MeshInstance3D:
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rings=20
 var sides=24
 for row in range(rings):
  for col in range(sides):
   for pair in [Vector2i(row,col),Vector2i(row+1,col),Vector2i(row,col+1),Vector2i(row,col+1),Vector2i(row+1,col),Vector2i(row+1,col+1)]:
    var theta=float(pair.x)/rings*PI
    var phi=float(pair.y)/sides*TAU
    var unit=Vector3(sin(theta)*cos(phi),cos(theta),sin(theta)*sin(phi))
    var p=center+unit*radius
    var t=clampf((p[axis]-low)/maxf(.01,high-low),0,1)
    var top=smoothstep(.48,1.0,t)
    var mid=smoothstep(0.0,.65,t)
    st.set_bones(PackedInt32Array([int(ids[0]),int(ids[1]),int(ids[2]),0]))
    st.set_weights(PackedFloat32Array([(1-mid)*(1-top),mid*(1-top),top,0.0]))
    st.set_normal((unit/radius).normalized())
    st.set_uv(Vector2(float(pair.y)/sides,float(pair.x)/rings))
    st.add_vertex(p)
 var node=MeshInstance3D.new()
 s.add_child(node)
 node.mesh=st.commit()
 node.skeleton=NodePath("..")
 node.skin=s.create_skin_from_rest_transforms()
 node.material_override=w.material(tint)
 return node


# Two-link target correction, applied after motion capture retargeting.
# CCD rotates parent joints in their own coordinate system; bone lengths stay fixed.
static func aim_chain(s:Skeleton3D,ids:Array,target:Vector3,weight:float=.75)->float:
 var tip=int(ids[2])
 for iteration in range(5):
  for j in [1,0]:
   s.force_update_all_bone_transforms()
   var id=int(ids[j])
   var current=s.get_bone_global_pose(id)
   var from=current.basis.inverse()*(s.get_bone_global_pose(tip).origin-current.origin)
   var to=current.basis.inverse()*(target-current.origin)
   if from.length_squared()<.00001 or to.length_squared()<.00001:continue
   var rotation=Quaternion(from.normalized(),to.normalized())
   var correction=Quaternion.IDENTITY.slerp(rotation,weight)
   s.set_bone_pose_rotation(id,(s.get_bone_pose_rotation(id)*correction).normalized())
 s.force_update_all_bone_transforms()
 return s.get_bone_global_pose(tip).origin.distance_to(target)

static func contact(w,r:Dictionary,a:Dictionary,moving:bool):
 var rig:Dictionary=r.get("skeletal",{})
 if rig.is_empty():return
 var kind=int(rig.get("kind",0))
 if kind==0:return
 var s:Skeleton3D=rig.skeleton
 var chains:Array=rig.extra
 var phase=float(r.phase)
 if kind==1:
  var prop=r.get("action_prop")
  if moving or not is_instance_valid(prop) or a.task_stage!="In corso" or str(a.task) not in ["farm","gather","craft","build","house","research","eat","heal"]:return
  for i in range(2):
   var p:Vector3=prop.to_global(Vector3((i*2-1)*.13,.015,.04))
   aim_chain(s,chains[i],s.to_local(p),.58)
 elif kind==2 and moving:
  for i in range(2):
   # During stance the hind foot follows the actual terrain surface.
   var gait=fposmod(phase+i*PI+PI*.5,TAU)
   if gait>PI:continue
   s.force_update_all_bone_transforms()
   var id=int(chains[i][2])
   var current=s.get_bone_global_pose(id).origin
   var foot=s.to_global(current)
   foot.y=w.walking_height(foot.x,foot.z)+.09*r.node.scale.y
   var goal=s.to_local(foot)
   goal.y=clampf(goal.y,current.y-.11,current.y+.11)
   aim_chain(s,chains[i],goal,.65)
