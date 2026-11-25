extends RefCounted
# Original modular meshes, no borrowed game models or screenshots.
static var roof_cache:Dictionary={}
static var canopy_cache:Dictionary={}
static func triangle(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,tint:Color):
 st.set_color(tint)
 st.add_vertex(a)
 st.add_vertex(b)
 st.add_vertex(c)
static func quad(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,d:Vector3,tint:Color):
 triangle(st,a,b,c,tint)
 triangle(st,a,c,d,tint)
static func vertex_material()->StandardMaterial3D:
 var m=StandardMaterial3D.new()
 m.vertex_color_use_as_albedo=true
 m.roughness=.91
 m.cull_mode=BaseMaterial3D.CULL_DISABLED
 return m
static func roof(parent:Node3D,tint:Color,h:float,variant:int):
 var key=tint.to_html()+str(variant)
 if not roof_cache.has(key):
  var st=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var rng=RandomNumberGenerator.new()
  rng.seed=47+variant
  for side in [-1,1]:
   for row in range(7):
    for col in range(10):
     var x0=float(row)/7*1.28
     var x1=float(row+1)/7*1.28+.035
     var z0=-1.30+float(col)*.26
     var z1=z0+.265
     var rise=.93 if variant==0 else 1.12
     var y0=rise*pow(maxf(0,1-x0/1.28),.83)+.055
     var y1=rise*pow(maxf(0,1-x1/1.28),.83)+.055
     var color=tint.lightened(rng.randf_range(-.15,.19))
     var a=Vector3(side*x0,y0,z0)
     var b=Vector3(side*x1,y1,z0)
     var c=Vector3(side*x1,y1,z1)
     var d=Vector3(side*x0,y0,z1)
     if side>0:quad(st,a,b,c,d,color)
     else:quad(st,d,c,b,a,color)
     # Raised tile rib creates a real profile, not a painted grid.
     var ridge=Vector3(0,.035,0)
     quad(st,a+ridge,d+ridge,d,a,color.darkened(.15))
   for end in [-1,1]:
    triangle(st,Vector3(0,.93 if variant==0 else 1.12,end*1.19),Vector3(side*1.24,0,end*1.19),Vector3(0,0,end*1.19),tint.darkened(.32))
  st.generate_normals()
  var mesh=st.commit()
  mesh.surface_set_material(0,vertex_material())
  roof_cache[key]=mesh
 var node=MeshInstance3D.new()
 node.mesh=roof_cache[key]
 parent.add_child(node)
 node.position.y=h
static func cottage(w,cover:Node3D,clan:int,era:int,j:int,h:float,tint:Color):
 var wood=Color("594636") if clan==0 else Color("754a34")
 var stone=Color("9b9581")
 var roof_tint=tint.lightened(.09) if clan==0 else Color("a56242")
 if era<4:
  roof(cover,roof_tint,h,j%2)
  for side in [-1,1]:
   w.block(cover,wood,Vector3(side*1.14,h+.035,0),Vector3(.14,.16,2.59))
   for z in [-1.05,0.0,1.05]:
    w.block(cover,wood,Vector3(side*1.08,h*.5,z),Vector3(.10,h,.10))
   for z in [-.56,.56]:
    var beam=w.block(cover,wood,Vector3(side*1.10,h*.53,z),Vector3(.10,h*.68,.08))
    beam.rotation.x=.42 if z>0 else -.42
   w.block(cover,wood,Vector3(side*1.08,h*.48,0),Vector3(.12,.11,2.2))
   for k in range(6):
    w.block(cover,stone.lightened(float(k%3)*.055),Vector3(side*1.08,.12,-.92+k*.36),Vector3(.20,.24,.34))
  # Open doorway is kept clear for the actual sleep service and interior view.
  w.block(cover,wood,Vector3(0,1.31,1.11),Vector3(1.06,.12,.16))
  for side in [-1,1]:
   w.block(cover,wood,Vector3(side*.76,h*.66,1.25),Vector3(.38,.065,.065))
   w.block(cover,wood,Vector3(side*.76,h*.66,1.25),Vector3(.055,.37,.065))
  if era>=2:
   w.block(cover,stone,Vector3(.72,h+.46,-.62),Vector3(.34,1.05,.34))
   w.block(cover,stone.darkened(.18),Vector3(.72,h+1.0,-.62),Vector3(.46,.14,.46))
  if j<18:
   # Small readable household details, no new fictitious buildings or collision.
   for side in [-1,1]:
    w.block(cover,wood.lightened(.18),Vector3(side*.86,.18,1.32),Vector3(.32,.28,.30))
    w.sphere(cover,Color("6c9164"),Vector3(side*.86,.40,1.32),Vector3(.28,.32,.27))
    w.sphere(cover,Color("e3bd78") if clan==0 else Color("ce846a"),Vector3(side*.86,.55,1.32),Vector3(.10,.12,.10))
  if j%3==0:
   var awning=w.block(cover,Color("bca36d"),Vector3(0,1.34,1.43),Vector3(1.12,.09,.65))
   awning.rotation.x=-.26
 else:
  var upper=Node3D.new()
  cover.add_child(upper)
  upper.position.y=h+.27
  upper.scale=Vector3(.80,.58,.80)
  roof(upper,tint.lightened(.12),0.0,j%2)
  for side in [-1,1]:
   for k in range(4):
    w.block(cover,Color("bec9b7"),Vector3(side*1.10,.40+k*.46,0),Vector3(.09,.11,2.13))
   w.block(cover,tint,Vector3(side*1.15,h+.22,0),Vector3(.15,.42,2.44))
  w.block(cover,Color("b7baab"),Vector3(0,.12,1.45),Vector3(1.4,.24,.55))
  for side in [-1,1]:
   w.block(cover,wood,Vector3(side*.88,h*.55,1.14),Vector3(.12,h*.85,.13))
   for floor_index in range(2):
    var y=.83+floor_index*.73
    w.block(cover,Color("344d50"),Vector3(side*.66,y,1.13),Vector3(.42,.38,.09))
    w.block(cover,Color("d9cda9"),Vector3(side*.66,y,1.19),Vector3(.048,.38,.045))
    w.block(cover,Color("d9cda9"),Vector3(side*.66,y,1.19),Vector3(.42,.048,.045))
   if j%2==0:
    w.block(cover,wood,Vector3(side*.79,1.35,1.46),Vector3(.64,.10,.48))
    for k in range(3):w.block(cover,wood,Vector3(side*.79+(k-1)*.22,1.52,1.66),Vector3(.05,.29,.05))
    w.block(cover,wood,Vector3(side*.79,1.67,1.66),Vector3(.64,.06,.06))
 # A small side yard, attached to the real house and removed with it.
 for side in [-1,1]:
  for k in range(3):
   w.block(cover,wood,Vector3(side*1.25,.23,-.68+k*.50),Vector3(.09,.46,.09))
  w.block(cover,wood.lightened(.12),Vector3(side*1.25,.27,-.18),Vector3(.07,.08,1.18))
static func pine(w,p:Vector3,h:float,index:int):
 var n=Node3D.new()
 w.scenery.add_child(n)
 n.position=p
 n.rotation.y=float(index)*2.39996
 n.scale=Vector3.ONE*h/3.5
 n.set_meta("vegetation",true)
 w.cone(n,Color("73503b"),Vector3.UP*1.13,.13,2.26,.065,8)
 var variant=posmod(index,8)
 if not canopy_cache.has(variant):
  var st=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var rng=RandomNumberGenerator.new()
  rng.seed=470+variant
  for layer in range(6):
   var y=1.02+layer*.40
   var radius=1.15-layer*.153
   var tint=Color("315c48").lerp(Color("71945d"),float(layer)/6)
   for k in range(14):
    var a=k*TAU/14+layer*.48
    var b=(k+1)*TAU/14+layer*.48
    var edge=Vector3(cos(a)*radius,y+rng.randf_range(-.13,.02),sin(a)*radius)
    var next=Vector3(cos(b)*radius,y+rng.randf_range(-.13,.02),sin(b)*radius)
    var mid=Vector3(cos((a+b)*.5)*radius*.75,y+.17,sin((a+b)*.5)*radius*.75)
    var tip=Vector3(0,y+.86,0)
    triangle(st,tip,edge,mid,tint.lightened(rng.randf_range(-.12,.15)))
    triangle(st,tip,mid,next,tint.lightened(rng.randf_range(-.08,.18)))
    triangle(st,Vector3(0,y-.10,0),next,edge,tint.darkened(.21))
  st.generate_normals()
  var mesh=st.commit()
  mesh.surface_set_material(0,vertex_material())
  canopy_cache[variant]=mesh
 var mi=MeshInstance3D.new()
 mi.mesh=canopy_cache[variant]
 n.add_child(mi)
static func field_plot(w,parent:Node3D,p:Vector3,clan:int,idx:int):
 var n=Node3D.new()
 parent.add_child(n)
 n.position=p
 n.rotation.y=float(clan)*PI*.5
 var soil=Color("755139")
 for row in range(4):
  w.block(n,soil.lightened(float(row%2)*.08),Vector3(0,.04,(row-1.5)*.44),Vector3(2.2,.10,.32))
  for k in range(6):
   var q=Vector3((k-2.5)*.34,.16,(row-1.5)*.44)
   if idx%2==0:
    w.sphere(n,Color("d5a03c"),q,Vector3(.28,.24,.28))
    for side in [-1,1]:
     var leaf=w.sphere(n,Color("729951"),q+Vector3(side*.13,.06,0),Vector3(.27,.055,.15))
     leaf.rotation.y=side*.5
   else:
    w.cone(n,Color("c8b56a"),q+Vector3.UP*.10,.055,.30,.025,5)
    w.cone(n,Color("e5c981"),q+Vector3.UP*.25,.065,.20,.02,5)
 for side in [-1,1]:
  for k in range(5):
   w.block(n,Color("745239"),Vector3((k-2)*.53,.26,side*1.03),Vector3(.08,.52,.08))
  w.block(n,Color("9b7650"),Vector3(0,.27,side*1.03),Vector3(2.22,.08,.07))
