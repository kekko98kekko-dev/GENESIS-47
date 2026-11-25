extends RefCounted
# One welded isosurface: smooth union of anatomical volumes, not merged
# disconnected submeshes. The topology is generated once and shared by rigs.
static var cached: ArrayMesh
const ORIGIN=Vector3(-.65,-.12,-.43)
const STEP=.045
const NX=30
const NY=42
const NZ=23
const CORNERS=[Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(1,1,0),Vector3i(0,1,0),Vector3i(0,0,1),Vector3i(1,0,1),Vector3i(1,1,1),Vector3i(0,1,1)]
const TETS=[[0,5,1,6],[0,1,2,6],[0,2,3,6],[0,3,7,6],[0,7,4,6],[0,4,5,6]]

static func ellipsoid(p:Vector3,c:Vector3,r:Vector3)->float:
 return ((p-c)/r).length()*minf(r.x,minf(r.y,r.z))-minf(r.x,minf(r.y,r.z))

static func capsule(p:Vector3,a:Vector3,b:Vector3,r:float)->float:
 var ab=b-a
 return (p-a-ab*clampf((p-a).dot(ab)/ab.length_squared(),0,1)).length()-r

static func union(a:float,b:float,k:float)->float:
 var h=clampf(.5+.5*(b-a)/k,0,1)
 return lerpf(b,a,h)-k*h*(1-h)

static func field(p:Vector3)->float:
 var d=ellipsoid(p,Vector3(0,.70,0),Vector3(.335,.40,.265))
 d=union(d,ellipsoid(p,Vector3(0,1.24,.025),Vector3(.385,.35,.325)),.09)
 d=union(d,capsule(p,Vector3(0,.94,0),Vector3(0,1.16,.025),.16),.07)
 for side in [-1,1]:
  d=union(d,capsule(p,Vector3(side*.29,.95,0),Vector3(side*.38,.76,0),.108),.075)
  d=union(d,capsule(p,Vector3(side*.38,.76,0),Vector3(side*.38,.56,0),.092),.045)
  d=union(d,ellipsoid(p,Vector3(side*.38,.54,0),Vector3(.11,.09,.11)),.04)
  d=union(d,capsule(p,Vector3(side*.18,.48,0),Vector3(side*.18,.26,0),.12),.075)
  d=union(d,capsule(p,Vector3(side*.18,.26,0),Vector3(side*.18,.11,0),.10),.045)
  d=union(d,ellipsoid(p,Vector3(side*.18,.095,.08),Vector3(.13,.075,.175)),.04)
 return d

static func normal_at(p:Vector3)->Vector3:
 var e=.003
 return Vector3(field(p+Vector3(e,0,0))-field(p-Vector3(e,0,0)),field(p+Vector3(0,e,0))-field(p-Vector3(0,e,0)),field(p+Vector3(0,0,e))-field(p-Vector3(0,0,e))).normalized()

static func idx(x:int,y:int,z:int)->int:return (z*NY+y)*NX+x

static func mesh_for(s:Skeleton3D)->ArrayMesh:
 if cached!=null:return cached
 var values=PackedFloat32Array()
 values.resize(NX*NY*NZ)
 for z in range(NZ):
  for y in range(NY):
   for x in range(NX):values[idx(x,y,z)]=field(ORIGIN+Vector3(x,y,z)*STEP)
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rests=[]
 for i in range(1,s.get_bone_count()):rests.append(s.get_bone_global_rest(i).origin)
 for z in range(NZ-1):
  for y in range(NY-1):
   for x in range(NX-1):
    var ps=[]
    var ds=[]
    var inside=0
    for off in CORNERS:
     var q=Vector3i(x,y,z)+off
     ps.append(ORIGIN+Vector3(q)*STEP)
     var d=values[idx(q.x,q.y,q.z)]
     ds.append(d)
     if d<0:inside+=1
    if inside==0 or inside==8:continue
    for tet in TETS:
     var cuts=[]
     for i in range(4):
      for j in range(i+1,4):
       var a=int(tet[i])
       var b=int(tet[j])
       if (float(ds[a])<0)==(float(ds[b])<0):continue
       # Canonical edge ordering for exact shared vertices.
       if a>b:
        var swap=a
        a=b
        b=swap
       var p:Vector3=ps[a].lerp(ps[b],float(ds[a])/(float(ds[a])-float(ds[b])))
       cuts.append(p.snapped(Vector3.ONE*.00001))
     if cuts.size()<3:continue
     var center=Vector3.ZERO
     for p in cuts:center+=p
     center/=cuts.size()
     var n=normal_at(center)
     var u=(Vector3(cuts[0])-center).normalized()
     var v=n.cross(u).normalized()
     cuts.sort_custom(func(a,b):return atan2((a-center).dot(v),(a-center).dot(u))<atan2((b-center).dot(v),(b-center).dot(u)))
     for i in range(1,cuts.size()-1):
      # Godot uses clockwise front faces.
      for p in [cuts[0],cuts[i+1],cuts[i]]:vertex(st,p,rests)
 st.index()
 cached=st.commit()
 return cached

static func vertex(st:SurfaceTool,p:Vector3,rests:Array):
 var nearest=[]
 for i in range(rests.size()):
  nearest.append({"id":i+1,"d":p.distance_squared_to(rests[i])})
 nearest.sort_custom(func(a,b):return float(a.d)<float(b.d))
 var ids=PackedInt32Array()
 var weights=PackedFloat32Array()
 var sum=0.0
 for i in range(4):
  ids.append(int(nearest[i].id))
  var w=1.0/pow(float(nearest[i].d)+.013,2.5)
  weights.append(w)
  sum+=w
 for i in range(4):weights[i]/=sum
 st.set_bones(ids)
 st.set_weights(weights)
 st.set_normal(normal_at(p))
 st.set_uv(Vector2(atan2(p.z,p.x)/TAU+.5,p.y/1.75))
 st.add_vertex(p)

static func build(w,s:Skeleton3D,tint:Color)->MeshInstance3D:
 var node=MeshInstance3D.new()
 s.add_child(node)
 node.mesh=mesh_for(s)
 node.skeleton=NodePath("..")
 node.skin=s.create_skin_from_rest_transforms()
 node.material_override=w.creature_skin(tint)
 return node
