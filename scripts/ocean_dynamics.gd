extends RefCounted
# Whole playable ocean: layered 3D velocities, hydrostatic free surface,
# hydrostatic pressure gradients and vertical mixing. Local splashes use
# the existing particle solver. Ocean mass is measured relative to rest.
const N=53
const L=8
const CELL=2.0
const DT=.075
var world
var wet=PackedByteArray()
var bed=PackedFloat32Array()
var eta=PackedFloat32Array()
var velocity=PackedVector3Array()
var elapsed=0.0
var revision=-1
var clock=0.0
var tex:ImageTexture
var active=false

func idx(x:int,z:int)->int:return z*N+x
func voxel(i:int,y:int)->int:return i*L+y
func sample_index(p:Vector3)->int:return idx(clampi(roundi(p.x/CELL)+26,0,N-1),clampi(roundi(p.z/CELL)+26,0,N-1))

func reset(w,data={}):
 world=w
 wet.resize(N*N)
 bed.resize(N*N)
 eta.resize(N*N)
 eta.fill(0)
 velocity.resize(N*N*L)
 velocity.fill(Vector3.ZERO)
 revision=-1
 elapsed=0
 clock=0
 active=true
 terrain()
 if data is Dictionary:
  for row in data.get("surface",[]):
   if row.size()==2 and int(row[0])>=0 and int(row[0])<eta.size() and wet[int(row[0])]:eta[int(row[0])]=float(row[1])
  for row in data.get("velocity",[]):
   if row.size()==4 and int(row[0])>=0 and int(row[0])<velocity.size():velocity[int(row[0])]=Vector3(float(row[1]),float(row[2]),float(row[3]))
 render()

func terrain():
 if revision==int(world.terrain_revision):return
 revision=int(world.terrain_revision)
 for z in range(N):
  for x in range(N):
   var i=idx(x,z)
   bed[i]=maxf(0,float(world.SEA)-float(world.height_at((x-26)*CELL,(z-26)*CELL)))
   wet[i]=1 if bed[i]>.15 else 0
   if not wet[i]:
    eta[i]=0
    for y in range(L):velocity[voxel(i,y)]=Vector3.ZERO

func export_state()->Dictionary:
 var surface=[]
 var flow=[]
 for i in range(eta.size()):
  if absf(eta[i])>.00001:surface.append([i,eta[i]])
 for i in range(velocity.size()):
  var v=velocity[i]
  if v.length_squared()>.000001:flow.append([i,v.x,v.y,v.z])
 return {"surface":surface,"velocity":flow}

func displacement()->float:
 var sum=0.0
 for i in range(eta.size()):
  if wet[i]:sum+=eta[i]
 return sum*CELL*CELL

func disturb(p:Vector3,amount:float):
 var i=sample_index(p)
 if not wet[i]:
  var best=INF
  var selected=-1
  for j in range(wet.size()):
   if not wet[j]:continue
   var q=Vector2((j%N-26)*CELL,(int(j/N)-26)*CELL)
   var d=q.distance_squared_to(Vector2(p.x,p.z))
   if d<best:best=d;selected=j
  if selected<0:return
  i=selected
 eta[i]+=amount
 for y in range(L):velocity[voxel(i,y)].y+=amount*.25*float(y+1)/L

func neighbor(x:int,z:int,i:int)->int:
 if x<0 or z<0 or x>=N or z>=N:return i
 var j=idx(x,z)
 return j if wet[j] else i

func step(dt:float):
 terrain()
 var next=velocity.duplicate()
 var flux=eta.duplicate()
 # Conservative face fluxes move surface volume between wet columns.
 for z in range(N):
  for x in range(N):
   var i=idx(x,z)
   if not wet[i]:continue
   for off in [Vector2i(1,0),Vector2i(0,1)]:
    var j=neighbor(x+off.x,z+off.y,i)
    if i==j:continue
    var avg=0.0
    for y in range(L):
     var a=velocity[voxel(i,y)]
     var b=velocity[voxel(j,y)]
     avg+=(a.x+b.x if off.x else a.z+b.z)*.5/L
    var transfer=clampf(avg*dt/CELL*minf(bed[i],bed[j]),-.12,.12)
    transfer=clampf(transfer,-maxf(0,bed[j]+flux[j]-.08)*.25,maxf(0,bed[i]+flux[i]-.08)*.25)
    flux[i]-=transfer
    flux[j]+=transfer
 # 3D layer velocity responds to head gradients, wind, vertical diffusion.
 for z in range(N):
  for x in range(N):
   var i=idx(x,z)
   if not wet[i]:continue
   var left=neighbor(x-1,z,i)
   var right=neighbor(x+1,z,i)
   var front=neighbor(x,z-1,i)
   var back=neighbor(x,z+1,i)
   var gradient=Vector3((eta[right]-eta[left])/(2*CELL),0,(eta[back]-eta[front])/(2*CELL))
   for y in range(L):
    var k=voxel(i,y)
    var v=velocity[k]-gradient*9.81*dt
    var below=velocity[voxel(i,maxi(0,y-1))]
    var above=velocity[voxel(i,mini(L-1,y+1))]
    v+=(below+above-2*velocity[k])*.8*dt
    var horizontal_div=(velocity[voxel(right,y)].x-velocity[voxel(left,y)].x+velocity[voxel(back,y)].z-velocity[voxel(front,y)].z)/(2*CELL)
    v.y-=horizontal_div*dt*minf(4,bed[i])
    if y==0:v.y=0
    if y==L-1:
     v.x+=sin(float(world.sim.day)*.15)*dt*.025
     v.z+=cos(float(world.sim.day)*.15)*dt*.025
     v.y=clampf((flux[i]-eta[i])/maxf(dt,.001),-2,2)
    if left==i and v.x<0 or right==i and v.x>0:v.x=0
    if front==i and v.z<0 or back==i and v.z>0:v.z=0
    next[k]=(v*.996).limit_length(5.0)
 eta=flux
 velocity=project(next,dt)
 clock+=dt

func current(p:Vector3)->Vector3:
 var i=sample_index(p)
 if wet.size()!=N*N or not wet[i]:return Vector3.ZERO
 var y=clampi(floori((p.y-(world.SEA-bed[i]))/maxf(.1,bed[i]+eta[i])*L),0,L-1)
 return velocity[voxel(i,y)]

func surface_at(p:Vector3)->float:
 return eta[sample_index(p)] if eta.size()==N*N else 0.0

func render():
 if not is_instance_valid(world.sea):return
 var img=Image.create(N,N,false,Image.FORMAT_RF)
 for z in range(N):
  for x in range(N):img.set_pixel(x,z,Color(eta[idx(x,z)],0,0,1))
 if tex==null:tex=ImageTexture.create_from_image(img)
 else:tex.update(img)
 world.sea.material_override.set_shader_parameter("ocean_displacement",tex)
 world.sea.material_override.set_shader_parameter("ocean_simulation",true)

func tick(dt:float):
 if not active:return
 elapsed+=minf(dt,.3)
 var count=0
 while elapsed>=DT and count<4:
  step(DT)
  elapsed-=DT
  count+=1
 if count>0:render()


# Approximate nonhydrostatic pressure correction on every wet 3D column.
# Cell-centred finite differences and fixed Jacobi sweeps are deliberately
# bounded; this is not a fully converged incompressible CFD solver.
func project(values:PackedVector3Array,dt:float)->PackedVector3Array:
 var p=PackedFloat32Array()
 var rhs=PackedFloat32Array()
 p.resize(values.size())
 rhs.resize(values.size())
 for z in range(N):
  for x in range(N):
   var i=idx(x,z)
   if not wet[i]:continue
   var dxm=neighbor(x-1,z,i)
   var dxp=neighbor(x+1,z,i)
   var dzm=neighbor(x,z-1,i)
   var dzp=neighbor(x,z+1,i)
   var dy=maxf(.15,(bed[i]+eta[i])/L)
   for y in range(L):
    var k=voxel(i,y)
    var below=values[voxel(i,maxi(0,y-1))]
    var above=values[voxel(i,mini(L-1,y+1))]
    rhs[k]=((values[voxel(dxp,y)].x-values[voxel(dxm,y)].x+values[voxel(dzp,y)].z-values[voxel(dzm,y)].z)/(2*CELL)+(above.y-below.y)/(2*dy))/maxf(dt,.001)
 for iteration in range(4):
  var updated=p.duplicate()
  for z in range(N):
   for x in range(N):
    var i=idx(x,z)
    if not wet[i]:continue
    var left=neighbor(x-1,z,i)
    var right=neighbor(x+1,z,i)
    var front=neighbor(x,z-1,i)
    var back=neighbor(x,z+1,i)
    var dy=maxf(.15,(bed[i]+eta[i])/L)
    var horizontal=1.0/(CELL*CELL)
    var vertical=1.0/(dy*dy)
    for y in range(L-1):
     var k=voxel(i,y)
     var sum=(p[voxel(left,y)]+p[voxel(right,y)]+p[voxel(front,y)]+p[voxel(back,y)])*horizontal
     sum+=(p[voxel(i,maxi(0,y-1))]+p[voxel(i,y+1)])*vertical
     updated[k]=(sum-rhs[k])/(4*horizontal+2*vertical)
  p=updated
 var result=values.duplicate()
 for z in range(N):
  for x in range(N):
   var i=idx(x,z)
   if not wet[i]:continue
   var left=neighbor(x-1,z,i)
   var right=neighbor(x+1,z,i)
   var front=neighbor(x,z-1,i)
   var back=neighbor(x,z+1,i)
   var dy=maxf(.15,(bed[i]+eta[i])/L)
   for y in range(L):
    var k=voxel(i,y)
    var grad=Vector3((p[voxel(right,y)]-p[voxel(left,y)])/(2*CELL),(p[voxel(i,mini(L-1,y+1))]-p[voxel(i,maxi(0,y-1))])/(2*dy),(p[voxel(back,y)]-p[voxel(front,y)])/(2*CELL))
    var v=(values[k]-grad*dt*.6).limit_length(5)
    if y==0:v.y=0
    if y==L-1:v.y=values[k].y
    if left==i and v.x<0 or right==i and v.x>0:v.x=0
    if front==i and v.z<0 or back==i and v.z>0:v.z=0
    result[k]=v
 return result

func absorb(p:Vector3,amount:float):
 var i=sample_index(p)
 if wet.size()==N*N and wet[i]:eta[i]+=amount
