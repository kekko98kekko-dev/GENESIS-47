extends RefCounted
# Presentation and urban design share the same actual simulated citizens/houses.
static func morphology(w,r:Dictionary,a:Dictionary):
 var rig:Dictionary=r.get("skeletal",{})
 if rig.is_empty():return
 if is_instance_valid(r.get("morph_node")):return
 var kind=0
 if float(a.genes[1])>.58:kind=1
 if float(a.genes[3])>.68:kind=2
 if float(a.genes[0])>.75 and float(a.genes[2])>.58:kind=3
 var body:Node3D=r.body
 var proportions=[Vector3(.68,.68,.68),Vector3(.89,.59,.83),Vector3(.55,.87,.56),Vector3(.72,.78,.65)]
 body.scale=proportions[kind]
 r["morph_kind"]=kind
 var n=Node3D.new()
 rig.head_anchor.add_child(n)
 r["morph_node"]=n
 var tint=Color("8bc5ac") if int(a.clan)==0 else Color("cd996d")
 match kind:
  0:
   for side in [-1,1]:
    var fin=w.cone(n,tint,Vector3(side*.37,.12,-.04),.11,.30,.015,7)
    fin.rotation.z=-side*.7
  1:
   for side in [-1,1]:
    var horn=w.cone(n,Color("d2c8a0"),Vector3(side*.30,.27,0),.11,.29,.008,7)
    horn.rotation.z=-side*.35
   w.sphere(n,tint.darkened(.18),Vector3(0,-.13,.27),Vector3(.40,.20,.20))
  2:
   for side in [-1,1]:
    w.sphere(n,tint.lightened(.25),Vector3(side*.29,.28,0),Vector3(.12,.39,.14))
   for eye in r.get("eyes",[]):eye.scale=Vector3(1.1,1.18,1)
  3:
   for j in range(5):
    var crest=w.cone(n,tint.lightened(.17),Vector3(0,.29,-.18+j*.075),.065,.18+float(j%2)*.08,.008,5)
    crest.rotation.x=-.5
 var tail=Node3D.new()
 rig.chest_anchor.add_child(tail)
 tail.position=Vector3(0,-.36,-.25)
 r["morph_tail"]=tail
 var length=[.20,.12,.36,.46][kind]
 for j in range(3):
  w.sphere(tail,tint.darkened(float(j)*.08),Vector3(0,-j*.045,-j*length*.33),Vector3(.16-j*.035,.16-j*.035,length*.5))
static func animate_morph(r:Dictionary,a:Dictionary,moving:bool):
 var tail=r.get("morph_tail")
 if is_instance_valid(tail):tail.rotation.y=sin(float(r.phase)*1.6)*(.36 if moving else .12)
 if not r.has("morph_kind"):return
 var k=int(r.morph_kind)
 var scales=[Vector3(.68,.68,.68),Vector3(.89,.59,.83),Vector3(.55,.87,.56),Vector3(.72,.78,.65)]
 r.body.scale=scales[k]
static func variant(a:Dictionary)->String:
 if float(a.genes[0])>.75 and float(a.genes[2])>.58:return "Crestato"
 if float(a.genes[3])>.68:return "Slanciato"
 if float(a.genes[1])>.58:return "Cornuto"
 return "Silvano"
# Connect real dwellings by a sparse growing street network instead of a
# separate radial road per house. Routes never bridge water visually.
static func streets(w,st:SurfaceTool,clan:int)->int:
 var points:Array=[w.centers[clan]]
 for home in w.houses[clan]:points.append(home.node.position)
 for row in w.districts.districts:
  if int(row.clan)==clan and not bool(row.ruined):points.append(w.ground(float(row.x),float(row.z)+2.2))
 var count=0
 for i in range(1,points.size()):
  var p:Vector3=points[i]
  var best=INF
  var neighbor=0
  for j in range(i):
   var d=p.distance_squared_to(points[j])
   if d<best:best=d;neighbor=j
  var q:Vector3=points[neighbor]
  count+=road(w,st,p,q,.34 if neighbor==0 else .23)
  if i%4==0 and i>2:
   var second=-1
   var second_d=INF
   for j in range(1,i):
    if j==neighbor:continue
    var d=p.distance_squared_to(points[j])
    if d<second_d:second_d=d;second=j
   if second>=0 and second_d<80:count+=road(w,st,p,points[second],.22)
 return count
static func road(w,st:SurfaceTool,p:Vector3,q:Vector3,width:float)->int:
 var dir=Vector2(q.x-p.x,q.z-p.z)
 if dir.length()<.2:return 0
 var side=dir.normalized().orthogonal()*width
 var count=0
 var steps=maxi(2,ceili(dir.length()/.55))
 for k in range(steps):
  var a=p.lerp(q,float(k)/steps)
  var b=p.lerp(q,float(k+1)/steps)
  var vertices=[w.ground(a.x+side.x,a.z+side.y)+Vector3.UP*.14,w.ground(a.x-side.x,a.z-side.y)+Vector3.UP*.14,w.ground(b.x+side.x,b.z+side.y)+Vector3.UP*.14,w.ground(b.x-side.x,b.z-side.y)+Vector3.UP*.14]
  if vertices.any(func(v):return v.y<w.SEA+.2):continue
  for v in [vertices[0],vertices[1],vertices[2],vertices[1],vertices[3],vertices[2]]:st.add_vertex(v)
  count+=2
 return count
static func plaza(w,parent:Node3D,clan:int):
 var v=w.sim.villages[clan]
 if int(v.era)<2:return
 var p:Vector3=w.land_near(w.centers[clan].x,w.centers[clan].z+4)
 var n=Node3D.new()
 parent.add_child(n)
 n.position=p
 var tint=Color("88b1a3") if clan==0 else Color("ca9b63")
 w.cone(n,Color("928e7f"),Vector3.UP*.08,2.1,.16,2.1,12)
 for j in range(8):
  var angle=j*TAU/8
  var pos=Vector3(cos(angle)*1.76,.22,sin(angle)*1.76)
  w.block(n,Color("b6b3a0"),pos,Vector3(.42,.24,.42))
  if j%2==0:
   w.cone(n,Color("6c7974"),pos+Vector3.UP*.34,.09,.70,.07,6)
   w.sphere(n,Color("f3d7a0"),pos+Vector3.UP*.75,Vector3(.18,.22,.18),.35)
  else:
   w.sphere(n,tint,pos+Vector3.UP*.34,Vector3(.45,.48,.45))
 w.cone(n,Color("6e9691"),Vector3.UP*.17,.68,.2,.68,12)
 w.cone(n,Color("67b4bb"),Vector3.UP*.29,.57,.05,.57,12,.25)
 w.cone(n,Color("c5c6ad"),Vector3.UP*.61,.18,.62,.08,8)
