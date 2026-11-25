extends RefCounted
# Imported textured models are used in real simulation locations, not a display-only map.
static var templates:Dictionary={}
static func named(w,kind:String,name:String)->int:
 var paths:Array=w.art_catalog.get(kind,[])
 for i in range(paths.size()):
  if str(paths[i]).get_file().get_basename().to_lower()==name.to_lower():return i
 return -1
static func model(w,parent:Node3D,kind:String,name:String,p:Vector3,h:float,angle:float=0.0,footprint:float=0.0)->Node3D:
 var i=named(w,kind,name)
 if i<0:return null
 var n:Node3D=w.asset(parent,kind,i,p,h,angle)
 if n==null:return null
 if footprint>0:
  var boxes:Array=w.mesh_bounds(n,n)
  if not boxes.is_empty():
   var b:AABB=boxes[0]
   for q in boxes:b=b.merge(q)
   n.scale*=minf(1.0,footprint/maxf(.01,maxf(b.size.x,b.size.z)))
 n.set_meta("reborn_asset",kind+"/"+name)
 return n
static func house(w,cover:Node3D,clan:int,era:int,j:int)->bool:
 if era>=4:return false
 var names=["house_1","house_2","house_3","house_4"]
 var n:Node3D
 if era==0:
  n=w.asset(cover,"early",j%3,Vector3.ZERO,1.95,0)
  if n!=null:
   var boxes:Array=w.mesh_bounds(n,n)
   if not boxes.is_empty():
    var b:AABB=boxes[0]
    for q in boxes:b=b.merge(q)
    n.scale*=minf(1.0,2.55/maxf(.01,maxf(b.size.x,b.size.z)))
   n.set_meta("reborn_asset","early")
 else:n=model(w,cover,"reborn_home",names[posmod(j+clan*2,4)],Vector3.ZERO,2.65 if era<3 else 3.05,0,2.55)
 if n==null:return false
 # Identity marker sits on the actual dwelling, not an additional building.
 var tint=Color("45978b") if clan==0 else Color("bf7850")
 w.block(cover,tint,Vector3(.91,.89,1.12),Vector3(.18,.32,.035))
 if j<12 and j%2==0:
  model(w,cover,"reborn_prop","crate",Vector3(-.79,0,1.14),.31,0,.35)
 return true
static func tree(w,p:Vector3,h:float,index:int,angle:float)->bool:
 # Avoid relying on the world class constant through a dynamic property.
 var b=preload("res://scripts/art_direction.gd").biome(w,p)
 var n:Node3D
 if b in [2,4,5] or index%3==0:
  n=model(w,w.scenery,"tree","pinetree_"+str(1+posmod(index,3)),p,h,angle)
 else:
  var names=["mapletree_1","mapletree_3","mapletree_5","birchtree_1","birchtree_3"]
  n=model(w,w.scenery,"reborn_tree",names[posmod(index,names.size())],p,h,angle)
 if n==null:return false
 n.set_meta("vegetation",true)
 return true
# Bake each imported static mesh part into a shared MultiMesh group. Each
# transform is independent, but there are no per-plant scene nodes.
static func mesh_parts(n:Node3D,root:Node3D,out:Array):
 if n is MeshInstance3D and n.mesh!=null:
  out.append({"mesh":n.mesh,"transform":root.global_transform.affine_inverse()*n.global_transform,"material":n.material_override})
 for c in n.get_children():
  if c is Node3D:mesh_parts(c,root,out)
static func batch(w,parent:Node3D,kind:String,name:String,placements:Array,height:float)->int:
 if placements.is_empty():return 0
 var key=kind+"/"+name+"/"+str(height)
 if not templates.has(key):
  var n=model(w,parent,kind,name,Vector3.ZERO,height)
  if n==null:return 0
  var parts=[]
  mesh_parts(n,n,parts)
  parent.remove_child(n)
  n.queue_free()
  templates[key]=parts
 var parts:Array=templates[key]
 for part in parts:
  var mm=MultiMesh.new()
  mm.transform_format=MultiMesh.TRANSFORM_3D
  mm.mesh=part.mesh
  mm.instance_count=placements.size()
  for i in range(placements.size()):mm.set_instance_transform(i,placements[i]*part.transform)
  var n=MultiMeshInstance3D.new()
  parent.add_child(n)
  n.multimesh=mm
  n.material_override=part.material
  n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  n.set_meta("reborn_asset",kind+"/"+name)
 return placements.size() if not parts.is_empty() else 0
static func understory(w):
 var rng=RandomNumberGenerator.new()
 rng.seed=w.sim.seed_value+903
 var extent=90.0 if w.vast_world else 47.0
 var groups=[[],[],[],[],[],[]]
 var names=["bush","bush_flowers","bush_small","flower_1_clump","flower_3_clump","grass_large"]
 var heights=[.62,.55,.38,.23,.24,.36]
 # Group vegetation close to actual trees and clear residential plots/roads.
 for i in range(1400 if w.vast_world else 850):
  if w.timber_points.is_empty():break
  var p:Vector3=w.timber_points[rng.randi_range(0,w.timber_points.size()-1)]
  p=w.ground(p.x+rng.randf_range(-2.5,2.5),p.z+rng.randf_range(-2.5,2.5))
  if absf(p.x)>extent or absf(p.z)>extent or p.y<w.SEA+.65 or p.y>9 or not w.far_village(p,6) or not w.away_from_route(p,1.2) or w.scarred(p):continue
  var k=posmod(i,names.size())
  groups[k].append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(.65,1.3)),p))
 for i in range(names.size()):batch(w,w.scenery,"reborn_understory",names[i],groups[i],heights[i])
static func crops(w,parent:Node3D,idx:int)->bool:
 var placements=[]
 for row in range(4):
  for k in range(7):
   var pos=Vector3((k-3)*.29,.11,(row-1.5)*.44)
   placements.append(Transform3D(Basis(Vector3.UP,float(k*7+row)*1.7),pos))
 return batch(w,parent,"reborn_crop","pumpkin_4" if idx%2==0 else "wheat_3",placements,.29 if idx%2==0 else .46)>0
static func civic(w,n:Node3D,index:int,era:int)->bool:
 if era>=4:return false
 var names=["inn","bell_tower","gazebo","bell_tower","blacksmith","stable"]
 var m=model(w,n,"reborn_civic",names[index],Vector3.ZERO,3.4 if index in [1,3] else 2.65,0,3.4)
 return m!=null
static func beast(w,n:Node3D,a:Dictionary)->bool:
 var names=["deer","mushroom","crab","demon"]
 var i=int(a.species)
 var size=.60+float(a.traits.size)*.44
 var item=model(w,n,"reborn_beast",names[i],Vector3.ZERO,size)
 if item==null:return false
 w.start_animation(item,["idle","walk"])
 return true
static func face(w,r:Dictionary,a:Dictionary):
 var rig:Dictionary=r.skeletal
 var h:Node3D=rig.head_anchor
 var kind=int(rig.kind)
 var tone=Color("729d83").lerp(Color("cad38a"),float(a.genes[2])) if int(a.clan)==0 else Color("9d6351").lerp(Color("d7b77b"),float(a.genes[2]))
 var dark=tone.darkened(.42)
 if kind==0:
  # Avian/forest face: tapered beak, lateral crest and coloured eye mask.
  var beak=w.cone(h,Color("cda365"),Vector3(0,-.13,.37),.16,.34,.025,9)
  beak.rotation.x=PI*.5
  for side in [-1,1]:
   var fin=w.sphere(h,tone,Vector3(side*.36,.12,-.02),Vector3(.17,.48,.28))
   fin.rotation.z=-side*.75
 elif kind==1:
  # Amphibian face: broad muzzle and luminous antennae, distinct outline.
  w.sphere(h,tone.darkened(.18),Vector3(0,-.15,.34),Vector3(.58,.25,.32))
  for side in [-1,1]:
   var stalk=w.cone(h,dark,Vector3(side*.21,.36,.03),.045,.35,.03,7)
   stalk.rotation.z=-side*.34
   w.sphere(h,Color("f2d997"),Vector3(side*.27,.53,.03),Vector3(.13,.15,.13),.13)
 else:
  # Armoured quadruped: muzzle, dorsal crown, broad sweeping horns.
  w.sphere(h,dark,Vector3(0,-.12,.33),Vector3(.43,.30,.40))
  for side in [-1,1]:
   var horn=w.cone(h,Color("b7ac85"),Vector3(side*.37,.20,-.06),.12,.48,.02,9)
   horn.rotation.z=-side*.88
   w.sphere(h,tone.lightened(.16),Vector3(side*.28,.06,.28),Vector3(.17,.09,.10))
 r["reborn_face"]=kind
