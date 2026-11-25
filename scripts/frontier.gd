extends RefCounted
# Larger optional landmass, keeping the original 106-unit simulation domain intact.
const EXTENT=96
const POINTS=[Vector2(-73,0),Vector2(0,-73),Vector2(73,0),Vector2(0,73)]
const NAMES=["Massiccio delle nuvole","Paludi d'argento","Deserto del sole","Selva delle origini"]
static func terrain(w,x:float,z:float,h:float)->float:
 var p=Vector2(x,z)
 for i in range(4):
  var c:Vector2=POINTS[i]
  var d=p.distance_to(c)
  if d<27:
   var peak=[18.0,3.0,7.0,8.0][i]
   var land=peak*(1-pow(d/23.0,1.65))-1.0+w.noise.get_noise_2d(x,z)*1.8
   h=maxf(h,land)
  var a=c.normalized()*27
  var b=c
  var ab=b-a
  var t=clampf((p-a).dot(ab)/ab.length_squared(),0,1)
  var width=p.distance_to(a+ab*t)
  if width<5.5:h=maxf(h,1.5-width*.28)
 return h

static func biome(p:Vector3)->int:
 if p.x<-52:return 5 if p.y>8 else 2
 if p.z<-52:return 4
 if p.x>52:return 3
 if p.z>52:return 1
 return -1

static func landmarks(w,parent:Node3D):
 for i in range(POINTS.size()):
  var q:Vector2=POINTS[i]
  var p:Vector3=w.ground(q.x,q.y)
  var n=Node3D.new()
  parent.add_child(n)
  n.position=p
  if i==0:
   # The water channel is now rendered by RiverSystem. The arch identifies
   # the entrance of the separately explorable cavern.
   for side in [-1,1]:w.cone(n,Color("596c70"),Vector3(side*.65,.65,1.5),.50,1.3,.34,7)
   w.block(n,Color("87918a"),Vector3(0,1.4,1.5),Vector3(1.8,.40,.72))
   w.block(n,Color("233538"),Vector3(0,.55,1.64),Vector3(.80,1.1,.07))
   w.sphere(n,Color("8ae1d0"),Vector3(0,1.72,1.5),Vector3(.17,.24,.17),.55)
   for side in [-1,1]:
    w.cone(n,Color("778a91"),Vector3(side*2,2,0),2.4,4.0,.25,6)
   w.cone(n,Color("cbdce0"),Vector3.UP*3.4,1.3,2.2,.02,7)
  elif i==1:
   for k in range(6):
    var a=k*TAU/6
    w.cone(n,Color("506e63"),Vector3(cos(a)*2,.1,sin(a)*2),.62,.2,.58,8)
    w.sphere(n,Color("679b83"),Vector3(cos(a)*2,.3,sin(a)*2),Vector3(1.0,.13,1.0))
   w.cone(n,Color("537e84"),Vector3.UP*.06,1.6,.12,1.6,16,.13)
  elif i==2:
   var volcano=Node3D.new()
   n.add_child(volcano)
   volcano.position=Vector3(5,0,-4)
   w.cone(volcano,Color("705649"),Vector3.UP*2,2.8,4.0,.70,12)
   w.cone(volcano,Color("dd8450"),Vector3.UP*4.02,.65,.08,.65,12,.6)
   for k in range(3):
    var tier=w.piece(n,PrismMesh.new(),Color("c6a36a"),Vector3(0,.5+k*.62,0),Vector3(4.6-k*1.2,1.4,3.1-k*.8))
    tier.rotation.y=PI*.5
  else:
   for k in range(5):
    var a=k*TAU/5
    w.cone(n,Color("79634a"),Vector3(cos(a)*2,1.4,sin(a)*2),.31,2.8,.18,8)
    w.sphere(n,Color("557c55"),Vector3(cos(a)*2,3.2,sin(a)*2),Vector3(2.8,2.0,2.8))
   w.cone(n,Color("a7c8ab"),Vector3.UP*.9,.7,1.8,.04,8,.3)
  var tag=Label3D.new()
  n.add_child(tag)
  tag.position.y=5
  tag.text=NAMES[i]
  tag.font_size=32
  tag.pixel_size=.011
  tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
