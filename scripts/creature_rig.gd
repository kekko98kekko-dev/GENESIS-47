extends RefCounted
const Mocap=preload("res://scripts/mocap_walk.gd")
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

static func build(w,body:Node3D,skin:Color,cloth:Color)->Dictionary:
 var skeleton=Skeleton3D.new()
 body.add_child(skeleton)
 var base=bone(skeleton,"Root",-1,Vector3.ZERO)
 var arm_ids=[]
 var leg_ids=[]
 for side in [-1,1]:
  var suffix="L" if side<0 else "R"
  var shoulder=bone(skeleton,"Shoulder"+suffix,base,Vector3(side*.34,.98,0))
  var elbow=bone(skeleton,"Elbow"+suffix,shoulder,Vector3(side*.04,-.22,0))
  var wrist=bone(skeleton,"Wrist"+suffix,elbow,Vector3(0,-.20,0))
  var hip=bone(skeleton,"Hip"+suffix,base,Vector3(side*.18,.43,0))
  var knee=bone(skeleton,"Knee"+suffix,hip,Vector3(0,-.17,0))
  var ankle=bone(skeleton,"Ankle"+suffix,knee,Vector3(0,-.15,0))
  arm_ids.append([shoulder,elbow,wrist])
  leg_ids.append([hip,knee,ankle])
  var hand=attach(skeleton,"Wrist"+suffix)
  w.sphere(hand,skin.lightened(.08),Vector3(0,-.02,0),Vector3(.22,.16,.22))
  var foot=attach(skeleton,"Ankle"+suffix)
  w.sphere(foot,skin,Vector3(0,-.015,.08),Vector3(.26,.15,.35))
 skeleton.reset_bone_poses()
 var skins=[]
 for i in range(2):
  var side=-1 if i==0 else 1
  skins.append(limb(w,skeleton,arm_ids[i],Vector3(side*.34,.98,0),Vector3(side*.04,-.22,0),Vector3(0,-.20,0),.105,skin))
  skins.append(limb(w,skeleton,leg_ids[i],Vector3(side*.18,.43,0),Vector3(0,-.17,0),Vector3(0,-.15,0),.114,skin.darkened(.06)))
 return {"skeleton":skeleton,"arm_ids":arm_ids,"leg_ids":leg_ids,"skins":skins}

static func drive(r:Dictionary,a:Dictionary,moving:bool,detail:bool,dt:float):
 var rig=r.get("skeletal",{})
 if rig.is_empty():return
 var s:Skeleton3D=rig.skeleton
 if not is_instance_valid(s):return
 var blend=clampf(dt*14,0,1)
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
  if moving and detail:
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
  pose(s,int(ai[0]),Vector3(ar.x,ar.y,ar.z),blend)
  pose(s,int(ai[1]),Vector3(elbow,0,0),blend)
  pose(s,int(ai[2]),Vector3(wrist,0,0),blend)
  pose(s,int(li[0]),Vector3(lr.x,lr.y,lr.z),blend)
  pose(s,int(li[1]),Vector3(knee,0,0),blend)
  pose(s,int(li[2]),Vector3(ankle,0,0),blend)

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
