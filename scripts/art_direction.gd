extends RefCounted
const Frontier=preload("res://scripts/frontier.gd")
# A visible identity for the two cultures, distinct landscape palettes and eras.
const BIOMES=["Prateria di giada","Bosco cremisi","Brughiera di pietra","Dune dell'alba","Selva della nebbia","Vetta delle nevi"]
const PALETTES=[["456e52","a8c47b"],["655448","bd9666"],["566b69","91aaa1"],["ad8050","e5c691"],["294f4a","659d86"],["808d91","e4ebeb"]]
static func biome(w,p:Vector3)->int:
 if w.vast_world:
  var frontier=Frontier.biome(p)
  if frontier>=0:return frontier
 if p.y>9.5:return 5
 if w.ocean.enabled:
  if Vector2(p.x,p.z).distance_to(w.REGION_POINTS[1])<13:return 4
  if Vector2(p.x,p.z).distance_to(w.REGION_POINTS[2])<13:return 3
 if p.x< -7 and p.z< -6:return 2
 if p.x>10 and p.z<6:return 1
 return 0

static func ground_color(w,p:Vector3,base:Color)->Color:
 if p.y<w.SEA+.75:return base
 var b=biome(w,p)
 var t=clampf(w.noise.get_noise_2d(p.x*.9+77,p.z*.9)*.9+.5,0,1)
 return base.lerp(Color(PALETTES[b][0]).lerp(Color(PALETTES[b][1]),t),.65)

static func tree(w,p:Vector3,h:float,i:int)->bool:
 var b=biome(w,p)
 if b not in [1,2,3,4,5] and i%4!=0:return false
 var n=Node3D.new()
 w.scenery.add_child(n)
 n.position=p
 n.rotation.y=float(i)*2.39996
 n.scale=Vector3.ONE*h/3.2
 n.set_meta("vegetation",true)
 var bark=Color("715a48")
 if b==3:
  w.cone(n,bark,Vector3.UP*1.25,.13,2.5,.08,8)
  for k in range(7):
   var a=k*TAU/7
   var leaf=w.sphere(n,Color("6e9b64"),Vector3(cos(a)*.65,2.55,sin(a)*.65),Vector3(.34,.16,1.5))
   leaf.rotation.y=-a+PI*.5
 elif b in [2,4,5]:
  w.cone(n,bark,Vector3.UP*.9,.16,1.8,.09,7)
  for k in range(4):
   var tint=Color("466b67").lightened(k*.07) if b==4 else Color("3f655d").lightened(k*.05)
   w.cone(n,tint,Vector3.UP*(1.25+k*.48),1.02-k*.20,1.23,.025,8)
   if b==5:w.cone(n,Color("dbe9e6"),Vector3.UP*(1.53+k*.48),.74-k*.14,.74,.018,8)
 else:
  w.cone(n,bark,Vector3.UP*.9,.17,1.8,.09,8)
  var tint=Color("ae704b") if b==1 else Color("507d56")
  for k in range(6):
   var a=k*TAU/6
   w.sphere(n,tint.lightened(float(k%3)*.12),Vector3(cos(a)*.45,2.0+float(k%2)*.32,sin(a)*.45),Vector3(1.26,1.05,1.26))
  w.sphere(n,tint.lightened(.2),Vector3.UP*2.78,Vector3(1.05,.75,1.05))
 return true

static func house(w,cover:Node3D,clan:int,era:int,j:int,h:float):
 var accent=Color("79baa8") if clan==0 else Color("d9a05e")
 var trim=Color("4b716a") if clan==0 else Color("794c3d")
 var stone=Color("b7b7a3") if clan==0 else Color("cbad89")
 for side in [-1,1]:
  w.block(cover,stone,Vector3(side*.99,.15,0),Vector3(.24,.3,2.16))
  w.block(cover,trim,Vector3(side*1.08,h*.5,.98),Vector3(.13,h,.13))
  w.block(cover,trim,Vector3(side*.76,h*.66,1.15),Vector3(.4,.46,.07))
  w.block(cover,Color("f3d49a"),Vector3(side*.76,h*.66,1.20),Vector3(.25,.28,.04),.27)
  w.block(cover,trim,Vector3(side*.76,h*.66,1.23),Vector3(.035,.28,.04))
  if era>=1:w.block(cover,accent,Vector3(side*.78,.18,1.20),Vector3(.42,.13,.35))
 if era<=1:
  for k in range(4):w.block(cover,trim,Vector3(0,.35+k*.28,-1.12),Vector3(2.05,.055,.04))
  if clan==1:w.cone(cover,Color("ae8258"),Vector3(0,h+.62,0),.95,.86,.03,8)
 elif era<=3:
  for k in range(5):
   w.block(cover,stone.darkened(.10),Vector3(-.88+k*.44,.39,-1.13),Vector3(.4,.16,.06))
  w.block(cover,trim,Vector3(.72,h+.56,-.55),Vector3(.29,.85,.31))
  w.block(cover,stone,Vector3(.72,h+1.01,-.55),Vector3(.40,.15,.42))
  if clan==0:
   var awning=w.block(cover,accent,Vector3(0,h*.64,1.43),Vector3(1.25,.09,.68))
   awning.rotation.x=-.18
  else:
   for side in [-1,1]:w.block(cover,accent,Vector3(side*.91,h+.24,.95),Vector3(.15,.42,.20))
 else:
  var height=.65+float(era-4)*.6+float(j%3)*.22
  w.block(cover,stone,Vector3(0,h+height*.5,-.27),Vector3(1.36,height,1.30))
  for k in range(era-2):
   w.block(cover,Color("476e78"),Vector3(0,h+.16+k*.21,.40),Vector3(1.13,.12,.055),.18)
  w.block(cover,trim,Vector3(0,h+height+.05,-.27),Vector3(1.5,.13,1.44))
  if era>=5:w.cone(cover,accent,Vector3(0,h+height+.45,-.27),.19,.73,.015,8,.55)

static func portrait(w,r:Dictionary,a:Dictionary):
 var rig:Dictionary=r.get("skeletal",{})
 if rig.is_empty():return
 var clan=int(a.clan)
 var age=float(a.age)
 var role=str(a.get("role","Esploratore"))
 var leader=int(w.sim.villages[clan].culture.leader)==int(a.id)
 var key=role+str(int(age/12))+str(leader)+str(int(w.sim.villages[clan].era))+str(int(a.get("sick",0)>0))+str(int(a.get("scars",0)))
 if r.get("identity_key","")==key:return
 r["identity_key"]=key
 if is_instance_valid(r.get("identity_head")):r.identity_head.hide();r.identity_head.queue_free()
 if is_instance_valid(r.get("identity_body")):r.identity_body.hide();r.identity_body.queue_free()
 var h=Node3D.new()
 var b=Node3D.new()
 rig.head_anchor.add_child(h)
 rig.chest_anchor.add_child(b)
 r["identity_head"]=h
 r["identity_body"]=b
 var accent=Color("e9c880") if clan==1 else Color("85cfba")
 var cloth=Color("795243") if clan==1 else Color("335c68")
 var skin=Color("e0ad78") if clan==1 else Color("8dceae")
 if age<14:
  w.sphere(h,accent,Vector3(0,.27,.06),Vector3(.24,.14,.22))
 elif age>55:
  for side in [-1,1]:w.sphere(h,Color("d8ded0"),Vector3(side*.22,.06,.25),Vector3(.15,.09,.045))
  w.sphere(h,Color("cbd2c5"),Vector3(0,-.19,.28),Vector3(.25,.20,.12))
 if leader or role=="Profeta":
  w.cone(h,accent,Vector3(0,.36,0),.25,.16,.22,9,.2)
  for k in range(5):w.cone(h,accent,Vector3(cos(k*TAU/5)*.22,.49,sin(k*TAU/5)*.22),.055,.15,.0,5,.15)
 elif role=="Coltivatore":
  w.cone(h,Color("a99862"),Vector3(0,.33,0),.42,.075,.37,12)
  w.cone(h,Color("bca66c"),Vector3(0,.42,0),.24,.19,.15,12)
 elif role=="Guardiano":
  w.sphere(h,Color("53676a"),Vector3(0,.23,-.015),Vector3(.70,.35,.63))
  w.block(b,Color("78939b"),Vector3(0,-.12,.24),Vector3(.46,.40,.09))
 elif role=="Ricercatore":
  for side in [-1,1]:w.sphere(h,Color("d7c88d"),Vector3(side*.18,.06,.39),Vector3(.22,.21,.045),.15)
  w.block(h,cloth,Vector3(0,.06,.4),Vector3(.13,.035,.025))
 elif role=="Artigiano":
  w.block(b,Color("a57c50"),Vector3(0,-.20,.24),Vector3(.40,.45,.065))
  for side in [-1,1]:w.block(b,cloth,Vector3(side*.12,-.13,.28),Vector3(.065,.48,.025))
 else:
  w.block(b,cloth,Vector3(.18,-.21,-.29),Vector3(.30,.42,.20))
  w.block(b,accent,Vector3(.18,-.08,-.40),Vector3(.26,.12,.035))
 if int(a.get("scars",0))>0:
  var scar=w.block(h,Color("89665a"),Vector3(.22,-.02,.29),Vector3(.035,.15,.025))
  scar.rotation.z=.48
 if int(a.get("sick",0))>0:w.sphere(h,Color("bf9b73"),Vector3(.22,-.09,.32),Vector3(.13,.085,.045))
 # Individual inherited crest/face proportions remain visible beneath clothing.
 var body:Node3D=r.body
 body.scale=Vector3(.61+.14*float(a.genes[1]),.61+.12*float(a.genes[3]),.63+.12*float(a.genes[2]))
