extends RefCounted
# Conservative terrain-following finite-volume flood model on a 2m grid.
# Each step transfers water down hydraulic head gradients; cell momentum is
# damped and used for erosion/structural stress. Closed boundaries conserve mass.
const N=53
const CELL=2.0
var world
var depth=PackedFloat32Array()
var ground_height=PackedFloat32Array()
var flow=PackedVector2Array()
var revision=-1
var visual:MeshInstance3D
var elapsed=0.0
var damage_clock=0.0
var total_added=0.0
var drained=0.0

func index(x:int,z:int)->int:return z*N+x
func point(i:int)->Vector2:return Vector2((i%N-26)*CELL,(int(i/N)-26)*CELL)
func cell(p:Vector3)->int:return index(clampi(roundi(p.x/CELL)+26,0,N-1),clampi(roundi(p.z/CELL)+26,0,N-1))

func reset(w,parent:Node3D,data={}):
 world=w
 depth.resize(N*N)
 depth.fill(0.0)
 ground_height.resize(N*N)
 flow.resize(N*N)
 flow.fill(Vector2.ZERO)
 revision=-1
 total_added=0.0
 drained=0.0
 elapsed=0.0
 damage_clock=0.0
 if data is Dictionary:
  for row in data.get("cells",[]):
   if row is Array and row.size()==2 and int(row[0])>=0 and int(row[0])<N*N:depth[int(row[0])]=clampf(float(row[1]),0,100)
  total_added=float(data.get("added",0))
  drained=float(data.get("drained",0))
 visual=MeshInstance3D.new()
 parent.add_child(visual)
 visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var mat=StandardMaterial3D.new()
 mat.albedo_color=Color(.09,.48,.63,.70)
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.cull_mode=BaseMaterial3D.CULL_DISABLED
 mat.roughness=.28
 visual.material_override=mat
 sample_terrain()
 redraw()

func sample_terrain():
 if revision==int(world.terrain_revision):return
 revision=int(world.terrain_revision)
 for i in range(N*N):
  var p=point(i)
  ground_height[i]=world.height_at(p.x,p.y)

func export_state()->Dictionary:
 var rows=[]
 for i in range(depth.size()):
  if depth[i]>.0001:rows.append([i,depth[i]])
 return {"cells":rows,"added":total_added,"drained":drained}

func mass()->float:
 var sum=0.0
 for value in depth:sum+=value
 return sum

func inject(p:Vector3,amount:float):
 sample_terrain()
 var i=cell(p)
 depth[i]+=amount
 total_added+=amount

func at(p:Vector3)->float:
 return depth[cell(p)] if depth.size()==N*N else 0.0

func step(dt:float):
 if depth.size()!=N*N:return
 sample_terrain()
 var next=depth.duplicate()
 var velocity=flow.duplicate()
 for z in range(N):
  for x in range(N):
   var i=index(x,z)
   if depth[i]<.00001:velocity[i]*=.8;continue
   var head=ground_height[i]+depth[i]
   var transfers=[]
   var sum=0.0
   for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
    var nx=x+d.x
    var nz=z+d.y
    if nx<0 or nx>=N or nz<0 or nz>=N:continue
    var j=index(nx,nz)
    var gradient=maxf(0,head-ground_height[j]-depth[j])
    var q=gradient*dt*.40
    if q>0:
     transfers.append([j,q,Vector2(d)])
     sum+=q
   var scale=minf(1.0,depth[i]*.75/maxf(sum,.00001))
   var impulse=Vector2.ZERO
   for row in transfers:
    var quantity=float(row[1])*scale
    next[i]-=quantity
    next[int(row[0])]+=quantity
    impulse+=Vector2(row[2])*quantity
   velocity[i]=flow[i]*.75+impulse/maxf(dt,.001)
 depth=next
 flow=velocity
 # Water entering existing sea is absorbed into the ocean reservoir.
 for i in range(depth.size()):
  if ground_height[i]<world.SEA-.25 and depth[i]>0:
   var lost=minf(depth[i],dt*.5)
   depth[i]-=lost
   drained+=lost

func redraw():
 if not is_instance_valid(visual):return
 var st=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var count=0
 for i in range(depth.size()):
  if depth[i]<.035 or ground_height[i]<world.SEA:continue
  var p=point(i)
  var y=ground_height[i]+depth[i]+.035
  var a=Vector3(p.x-1,y,p.y-1)
  var b=Vector3(p.x+1,y,p.y-1)
  var c=Vector3(p.x-1,y,p.y+1)
  var d=Vector3(p.x+1,y,p.y+1)
  for v in [a,b,c,b,d,c]:
   st.set_normal(Vector3.UP)
   st.add_vertex(v)
  count+=1
 visual.mesh=st.commit() if count>0 else null

func tick(dt:float):
 if depth.is_empty() or mass()<.001:return
 elapsed+=minf(dt,.5)
 damage_clock+=dt
 if elapsed>=.20:
  step(.20)
  elapsed-=.20
  redraw()
 if damage_clock>=2:
  damage_clock=0.0
  world.flood_damage(self)
