extends RefCounted
const Artisan=preload("res://scripts/artisan_kit.gd")
# Civic districts grow from actual population, housing and technology.
var world
var root:Node3D
var districts:Array=[]
var nodes:Dictionary={}
var signature=""
const SERVICE_KINDS=["eat","research","play","research","craft","heal"]
const NAMES=["Mercato","Archivio","Piazza","Università","Officine","Ospedale"]
func reset(w,data={}):
 world=w
 districts=data.get("districts",[]) if data is Dictionary else []
 nodes.clear()
 signature=""
func export_state()->Dictionary:return {"districts":districts}
func build(parent:Node3D):
 root=parent
 nodes.clear()
 signature=""
 sync()
func sync():
 if not is_instance_valid(root):return
 var key=""
 for i in range(2):
  var v=world.sim.villages[i]
  key+=str(v.era)+":"+str(v.houses)+":"+str(world.sim.count(i))+";"
 if key==signature:return
 signature=key
 for clan in range(2):
  var v=world.sim.villages[clan]
  var target=mini(6,mini(int(v.era),int(v.houses/3)))
  for i in range(target):
   if districts.any(func(d):return int(d.clan)==clan and int(d.index)==i):continue
   var angle=float(i)*TAU/6+clan*.4
   var center:Vector3=world.centers[clan]
   var p=world.land_near(center.x+cos(angle)*12,center.z+sin(angle)*12)
   if p.y<=world.SEA+.5 or float(v.wood)<6:continue
   v.wood-=6
   world.services_dirty=true
   districts.append({"clan":clan,"index":i,"x":p.x,"z":p.z,"era":int(v.era),"founded":world.sim.day,"ruined":false})
  for row in districts:
   if int(row.clan)!=clan:continue
   row.era=int(v.era)
   var id=str(clan)+":"+str(row.index)
   var is_ruined=world.sim.count(clan)==0 or bool(row.get("ruined",false))
   if world.sim.count(clan)==0:row.ruined=true
   var era=int(v.era)
   var stamp=str(era)+str(is_ruined)
   if nodes.has(id) and nodes[id].get_meta("stamp")==stamp:continue
   if nodes.has(id):nodes[id].hide();nodes[id].queue_free()
   var n=Node3D.new()
   root.add_child(n)
   n.position=world.ground(float(row.x),float(row.z))
   n.set_meta("stamp",stamp)
   nodes[id]=n
   if is_ruined:
    for j in range(5):
     var b=world.block(n,Color("8a897a"),Vector3((j-2)*.37,.24,sin(j)*.4),Vector3(.32,.48,.42))
     b.rotation.z=float(j-2)*.16
    continue
   var tint=Color("78afa5") if clan==0 else Color("b78a60")
   var stone=Color("a9aa96") if clan==0 else Color("c7ae8b")
   var accent=Color("365f5e") if clan==0 else Color("955333")
   world.block(n,stone,Vector3(0,.10,0),Vector3(3.5,.20,3.5))
   for j in range(3):
    var h=1.7+maxf(0,era-2)*.8+float(j%2)*.55
    var kind=int(row.index)
    if kind==0 or kind==2:h*=.68
    elif kind==1 or kind==3:h*=1.30 if j==1 else .83
    elif kind==4:h*=1.15 if j!=1 else .75
    elif kind==5:h*=.86
    var x=(j-1)*1.05
    var facade=world.block(n,stone,Vector3(x,h*.5,0),Vector3(.86,h,1.45))
    facade.material_override=world.architecture_material(stone,.85,0)
    for side in [-1,1]:
     world.block(n,accent,Vector3(x+side*.43,h*.5,.76),Vector3(.09,h,.09))
     for level in range(1,ceili(h/.56)):
      var y=level*.56
      if y<h-.12:world.block(n,Color("d3b875"),Vector3(x+side*.19,y,.755),Vector3(.21,.29,.05),.08)
    if era<4:
     var roof_base=Node3D.new()
     n.add_child(roof_base)
     roof_base.position=Vector3(x,h,0)
     roof_base.scale=Vector3(.43,.69,.64)
     Artisan.roof(roof_base,accent,0.0,j%2)
    else:
     world.block(n,tint,Vector3(x,h+.11,0),Vector3(1.0,.22,1.60))
     for floor_index in range(2+era):
      var y=.4+floor_index*.46
      if y<h:world.block(n,Color("476e78"),Vector3(x,y,.75),Vector3(.64,.18,.045),.25)
     if era>=5:world.cone(n,tint,Vector3(x,h+.48,0),.10,.7,.02,6,.3)
   if era>=3 and int(row.index) in [1,3,5]:
    for side in [-1,1]:
     var tower=world.cone(n,stone,Vector3(side*1.40,1.7,-.58),.34,3.4,.30,10)
     tower.material_override=world.architecture_material(stone,.85,0)
     world.cone(n,accent,Vector3(side*1.4,3.73,-.58),.51,.92,.025,10)
     for j in range(3):world.block(n,Color("4b5d5a"),Vector3(side*1.4,1.0+j*.75,-.25),Vector3(.12,.28,.05))
   # Functional district silhouettes differ by existing service type.
   match int(row.index):
    0:
     for side in [-1,1]:world.block(n,tint,Vector3(side*.85,1.15,1.4),Vector3(1.45,.12,.85))
    1,3:
     world.cone(n,accent,Vector3(0,3.25+maxf(0,era-2)*.65,-.4),.38,1.15,.035,8)
    2:
     world.cone(n,tint,Vector3(0,.28,1.3),.48,.25,.48,12)
    4:
     world.cone(n,stone.darkened(.25),Vector3(.9,2.45+maxf(0,era-2)*.8,-.65),.22,1.6,.20,8)
    5:
     world.block(n,Color("bde2d6"),Vector3(0,1.26,1.65),Vector3(.72,.16,.08),.15)
     world.block(n,Color("bde2d6"),Vector3(0,1.26,1.65),Vector3(.16,.72,.08),.15)
   var door=Vector3(0,.1,1.4)
   for side in [-1,1]:world.block(n,tint,door+Vector3(side*1.25,.40,0),Vector3(.25,.6,.25))
   for stripe in range(5):world.block(n,tint if stripe%2==0 else Color("e7d8b7"),Vector3(-.64+stripe*.32,1.05,1.45),Vector3(.32,.11,.62))
   var tag=Label3D.new()
   n.add_child(tag)
   tag.position.y=2.5+maxf(0,era-2)*.8
   tag.text=NAMES[int(row.index)]
   tag.font_size=25
   tag.pixel_size=.008
   tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
func damage(p:Vector3,radius:float):
 for row in districts:
  if Vector2(float(row.x)-p.x,float(row.z)-p.z).length()<radius:row.ruined=true
 signature=""
 world.services_dirty=true
 sync()

# These service stations are claimed and occupied using the existing real
# citizen routes, capacities and task completion, not decorative crowds.
func register_stations():
 for row in districts:
  if bool(row.ruined) or world.sim.count(int(row.clan))==0:continue
  var i=int(row.index)
  var p=world.ground(float(row.x),float(row.z)+2.2)
  var key=world.register_service(SERVICE_KINDS[i],int(row.clan),p,4+mini(8,int(row.era)),NAMES[i],false)
  if key!="":world.services[key]["district"]=i

func report()->String:
 var visits=0
 var capacity=0
 for key in world.services:
  var service=world.services[key]
  if not service.has("district"):continue
  capacity+=int(service.capacity)
  for claim in world.claims.values():
   if claim==key:visits+=1
 return "Quartieri civici · %d distretti · %d posti di servizio · %d prenotazioni"%[districts.size(),capacity,visits]
