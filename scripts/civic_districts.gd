extends RefCounted
# Civic districts grow from actual population, housing and technology.
var world
var root:Node3D
var districts:Array=[]
var nodes:Dictionary={}
var signature=""
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
   districts.append({"clan":clan,"index":i,"x":p.x,"z":p.z,"era":int(v.era),"founded":world.sim.day,"ruined":false})
  for row in districts:
   if int(row.clan)!=clan:continue
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
   var stone=Color("b4b8a8") if clan==0 else Color("c7ae8b")
   world.block(n,stone,Vector3(0,.10,0),Vector3(3.5,.20,3.5))
   for j in range(3):
    var h=1.7+maxf(0,era-2)*.8+float(j%2)*.55
    var x=(j-1)*1.05
    world.block(n,stone,Vector3(x,h*.5,0),Vector3(.86,h,1.45))
    if era<4:
     world.cone(n,tint,Vector3(x,h+.38,0),.75,.76,.08,clan*2+6)
    else:
     world.block(n,tint,Vector3(x,h+.11,0),Vector3(1.0,.22,1.60))
     for floor_index in range(2+era):
      var y=.4+floor_index*.46
      if y<h:world.block(n,Color("476e78"),Vector3(x,y,.75),Vector3(.64,.18,.045),.25)
     if era>=5:world.cone(n,tint,Vector3(x,h+.48,0),.10,.7,.02,6,.3)
   var tag=Label3D.new()
   n.add_child(tag)
   tag.position.y=2.5+maxf(0,era-2)*.8
   tag.text=["Quartiere","Archivio","Piazza","Università","Distretto","Osservatorio"][int(row.index)]
   tag.font_size=25
   tag.pixel_size=.008
   tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
func damage(p:Vector3,radius:float):
 for row in districts:
  if Vector2(float(row.x)-p.x,float(row.z)-p.z).length()<radius:row.ruined=true
 signature=""
 sync()
