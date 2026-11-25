extends RefCounted
# Two terrain-fed streams. Each section stores water volume; transfer is
# down the hydraulic gradient, with metered spring input and outlet discharge.
const PATHS=[[[ -73,3],[-72,7],[-74,12],[-71,17],[-69,22],[-67,27]],[[0,73],[4,73],[8,74],[13,72],[18,70],[24,67]]]
const WIDTH=1.35
var world
var root:Node3D
var streams:Array=[]
var meshes:Array=[]
var clock=0.0
var supplied=0.0
var discharged=0.0
var initial=0.0

static func path_points(index:int)->Array:
 var result=[]
 var path:Array=PATHS[index]
 for j in range(path.size()-1):
  var a=Vector2(float(path[j][0]),float(path[j][1]))
  var b=Vector2(float(path[j+1][0]),float(path[j+1][1]))
  var steps=maxi(1,ceili(a.distance_to(b)/1.4))
  for k in range(steps):result.append(a.lerp(b,float(k)/steps))
 var last:Array=path.back()
 result.append(Vector2(float(last[0]),float(last[1])))
 return result

static func carve(x:float,z:float,h:float)->float:
 var p=Vector2(x,z)
 for route in PATHS:
  for j in range(route.size()-1):
   var a=Vector2(float(route[j][0]),float(route[j][1]))
   var b=Vector2(float(route[j+1][0]),float(route[j+1][1]))
   var ab=b-a
   var t=clampf((p-a).dot(ab)/ab.length_squared(),0,1)
   var d=p.distance_to(a+ab*t)
   if d<1.8:h-=.8*pow(1-d/1.8,2)
 return h

func reset(w,parent:Node3D,data={}):
 world=w
 root=parent
 streams=[]
 meshes=[]
 clock=0
 supplied=float(data.get("supplied",0))
 discharged=float(data.get("discharged",0))
 initial=float(data.get("initial",0))
 if not world.vast_world:return
 for i in range(PATHS.size()):
  var cells=[]
  var points=path_points(i)
  for p in points:
   cells.append({"x":p.x,"z":p.y,"volume":.20})
  var saved:Array=data.get("streams",[])
  if i<saved.size() and saved[i].size()==cells.size():
   for j in range(cells.size()):cells[j].volume=maxf(0,float(saved[i][j]))
  streams.append(cells)
  var mesh=MeshInstance3D.new()
  root.add_child(mesh)
  var mat=StandardMaterial3D.new()
  mat.albedo_color=Color("4d9fb3")
  mat.roughness=.22
  mat.metallic=.14
  mat.cull_mode=BaseMaterial3D.CULL_DISABLED
  mesh.material_override=mat
  meshes.append(mesh)
 if not data.has("initial"):initial=mass()
 render()

func mass()->float:
 var amount=0.0
 for stream in streams:
  for cell in stream:amount+=float(cell.volume)
 return amount
func export_state()->Dictionary:
 var rows=[]
 for stream in streams:
  var volumes=[]
  for cell in stream:volumes.append(cell.volume)
  rows.append(volumes)
 return {"streams":rows,"initial":initial,"supplied":supplied,"discharged":discharged}
func height(cell:Dictionary)->float:return float(world.height_at(float(cell.x),float(cell.z)))
func step(dt:float):
 for stream in streams:
  var source=dt*(.7 if world.sim.weather_name=="Pioggia" else .12 if world.sim.weather_name=="Siccità" else .32)
  stream[0].volume+=source
  supplied+=source
  var change=PackedFloat32Array()
  change.resize(stream.size())
  for i in range(stream.size()-1):
   var a:Dictionary=stream[i]
   var b:Dictionary=stream[i+1]
   var head=height(a)+float(a.volume)/WIDTH-height(b)-float(b.volume)/WIDTH
   var q=clampf(head*dt*.45,-float(b.volume)*.4,float(a.volume)*.4)
   change[i]-=q
   change[i+1]+=q
  for i in range(stream.size()):stream[i].volume=maxf(0,float(stream[i].volume)+change[i])
  var last:Dictionary=stream.back()
  var drain=minf(float(last.volume),dt*.5)
  last.volume-=drain
  discharged+=drain
func render():
 for i in range(streams.size()):
  var stream:Array=streams[i]
  var st=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for j in range(stream.size()-1):
   var a:Dictionary=stream[j]
   var b:Dictionary=stream[j+1]
   if float(a.volume)+float(b.volume)<.025:continue
   var p=Vector3(float(a.x),height(a)+.06+minf(.75,float(a.volume)/WIDTH),float(a.z))
   var q=Vector3(float(b.x),height(b)+.06+minf(.75,float(b.volume)/WIDTH),float(b.z))
   var side=Vector3(q.z-p.z,0,p.x-q.x).normalized()*clampf(.25+float(a.volume)*.4,.28,.75)
   for v in [p-side,p+side,q-side,p+side,q+side,q-side]:
    st.set_normal(Vector3.UP)
    st.add_vertex(v)
  meshes[i].mesh=st.commit()
func tick(dt:float):
 clock+=minf(dt,.5)
 if clock<.2:return
 clock-=.2
 step(.2)
 render()
func report()->String:return "Fiumi · %d sorgenti · volume %.1f · deflusso %.1f"%[streams.size(),mass(),discharged]
