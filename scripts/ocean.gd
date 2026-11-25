extends RefCounted
const ColonyLife=preload("res://scripts/colony_life.gd")
const Finance=preload("res://scripts/finance.gd")
var life=ColonyLife.new()
var finance=Finance.new()
const Industry=preload("res://scripts/industry.gd")
var industry=Industry.new()
# Independent colonies, sea transport and double-entry trade. Simulation is daily;
# graphical ships interpolate between departure and arrival.
const GOODS=["food","wood","stone","tools","ore","flour","bread","planks","bricks","metal","machines"]
const LABELS={"food":"Cibo","wood":"Legna","stone":"Pietra","tools":"Utensili","ore":"Minerale","flour":"Farina","bread":"Pane","planks":"Tavole","bricks":"Mattoni","metal":"Metallo","machines":"Macchinari"}
const BASE={"food":2.0,"wood":3.0,"stone":4.0,"tools":8.0,"ore":3.0,"flour":4.0,"bread":4.0,"planks":6.0,"bricks":8.0,"metal":9.0,"machines":30.0}
var world
var enabled=false
var colonies:Array=[]
var voyages:Array=[]
var accounts:Array=[]
var history:Array=[]
var next_id=1
var completed=0
var delayed=0
var failed=0
var turnover=0.0
var root:Node3D
var fleet:Dictionary={}
var colony_nodes:Dictionary={}
var sea_grid=AStarGrid2D.new()
var sea_revision=-1
var routes:Dictionary={}

func reset(w,on:bool):
 world=w
 enabled=on
 colonies=[]
 voyages=[]
 accounts=[]
 history=[]
 next_id=1
 completed=0
 delayed=0
 failed=0
 turnover=0
 for i in range(2):accounts.append({"cash":150.0,"stone":0.0,"tools":0.0})
 world.sim.market_mode=enabled
 life.setup(self)
 finance.setup(self)
 industry.setup(self)

func export_state()->Dictionary:
 return {"enabled":enabled,"colonies":colonies,"voyages":voyages,"accounts":accounts,"history":history,"next_id":next_id,"completed":completed,"delayed":delayed,"failed":failed,"turnover":turnover,"finance":finance.export_state(),"industry":industry.export_state()}

func restore(w,data):
 reset(w,false)
 if not data is Dictionary or not bool(data.get("enabled",false)):return
 enabled=true
 world.sim.market_mode=true
 colonies=data.get("colonies",[])
 voyages=data.get("voyages",[])
 accounts=data.get("accounts",accounts)
 history=data.get("history",[])
 if not colonies is Array:colonies=[]
 if not voyages is Array:voyages=[]
 if not accounts is Array or accounts.size()!=2:accounts=[{"cash":150.0,"stone":0.0,"tools":0.0},{"cash":150.0,"stone":0.0,"tools":0.0}]
 if not history is Array:history=[]
 next_id=maxi(1,int(data.get("next_id",1)))
 completed=int(data.get("completed",0))
 delayed=int(data.get("delayed",0))
 failed=int(data.get("failed",0))
 turnover=float(data.get("turnover",0))
 finance.restore(data.get("finance",{}))
 industry.restore(data.get("industry",{}))
 for c in colonies:life.migrate(c)

func colony(id:int)->Dictionary:
 for c in colonies:
  if int(c.id)==id:return c
 return {}

func port_name(id:int)->String:
 if id<2:return str(world.sim.CLANS[id])
 var c=colony(id)
 return str(c.get("name","Porto sconosciuto"))

func port_clan(id:int)->int:
 if id<2:return id
 return int(colony(id).get("clan",0))

func port_population(id:int)->int:
 if id<2:return world.sim.count(id)
 return int(colony(id).get("population",0))

func balance(id:int,good:String)->float:
 if id<2:
  if good in ["food","wood"]:return float(world.sim.villages[id].get(good,0))
  return float(accounts[id].get(good,0))
 return float(colony(id).get(good,0))

func change(id:int,good:String,amount:float):
 if id<2:
  if good in ["food","wood"]:world.sim.villages[id][good]=maxf(0,balance(id,good)+amount)
  else:accounts[id][good]=maxf(0,balance(id,good)+amount)
 else:
  var c=colony(id)
  if not c.is_empty():c[good]=maxf(0,balance(id,good)+amount)

func target(id:int,good:String)->float:
 var n=maxi(1,port_population(id))
 match good:
  "food":return maxf(12,n*3.0)
  "wood":return maxf(10,n*1.5)
  "stone":return maxf(6,n*.75)
  "tools":return maxf(3,n*.25)
  "ore","flour","planks","bricks","metal":return maxf(4,n*.35)
  "bread":return maxf(4,n*.8)
  "machines":return maxf(2,n*.10)
 return 1.0

func price(id:int,good:String)->float:
 var ratio=balance(id,good)/target(id,good)
 return snappedf(float(BASE[good])*clampf(1.65-ratio*.55,.45,2.5),.1)

func record(message:String):
 history.push_front("G%d · %s"%[world.sim.day,message])
 if history.size()>40:history.pop_back()
 world.sim.log_event(message)

func work_completed(a:Dictionary,kind:String,coins_before:float):
 if not enabled:return
 var clan=int(a.clan)
 if kind in ["farm","gather","build","house","research","craft","guard"]:
  var wage=minf(1.5,balance(clan,"cash"))
  change(clan,"cash",-wage)
  var contribution=minf(.25,wage)
  a.coins=coins_before+wage-contribution
  world.sim.villages[clan].culture.treasury+=contribution
 if kind=="gather":
  change(clan,"stone",.55)
  change(clan,"ore",.35)
 if kind=="craft":change(clan,"tools",1.0)
 if kind=="eat":change(clan,"cash",maxf(0,coins_before-float(a.coins)))
 if kind in ["farm","gather","build","house"] and float(a.tool)<15 and balance(clan,"tools")>=1:
  var cost=price(clan,"tools")
  if float(a.coins)>=cost:
   a.coins-=cost
   change(clan,"cash",cost)
   change(clan,"tools",-1)
   a.tool=100.0
 if kind=="eat":consume_bread(clan,a)
 if kind in ["build","house"]:use_materials(clan,a)

func consume_bread(port:int,a:Dictionary):
 if balance(port,"bread")<1:return
 var cost=price(port,"bread")
 if float(a.coins)<cost:return
 change(port,"bread",-1)
 a.coins-=cost
 change(port,"cash",cost)
 a.hunger=maxf(0,float(a.hunger)-12)
 a.mood=minf(100,float(a.mood)+3)

func use_materials(port:int,a:Dictionary):
 if balance(port,"planks")>=1 and balance(port,"bricks")>=1:
  change(port,"planks",-1)
  change(port,"bricks",-1)
  a.skill=minf(100,float(a.skill)+.5)
 if balance(port,"machines")>=1 and float(a.tool)<85:
  change(port,"machines",-.1)
  a.tool=minf(100,float(a.tool)+15)

func recruit(clan:int,region:int)->bool:
 if not enabled or region not in [1,2] or world.sim.villages[clan].tech<2:return false
 for c in colonies:
  if int(c.region)==region:return false
 for v in voyages:
  if v.kind=="settle" and int(v.region)==region:return false
 if voyages.size()>=8 or world.sim.count(clan)<10:return false
 var village=world.sim.villages[clan]
 if float(village.food)<35 or float(village.wood)<24 or balance(clan,"cash")<20:return false
 var candidates=world.sim.people.filter(func(a):return int(a.clan)==clan and float(a.age)>=18 and float(a.health)>=65 and int(a.partner)<0 and not bool(a.favorite))
 if candidates.size()<2:return false
 var crew=[]
 for a in candidates.slice(0,2):
  finance.settle_depositor(clan,int(a.id))
  var migrant:Dictionary=a.duplicate(true)
  for key in ["position","path","path_index","task","task_stage","target_id","home","remaining"]:migrant.erase(key)
  migrant.friend=-1
  crew.append(migrant)
  for other in world.sim.people:
   if int(other.friend)==int(a.id):other.friend=-1
  world.sim.people.erase(a)
  world.sim.changes.append({"kind":"emigration","id":a.id})
 change(clan,"food",-25)
 change(clan,"wood",-18)
 change(clan,"cash",-20)
 var row={"id":next_id,"kind":"settle","seller":clan,"buyer":-1,"region":region,"crew":crew,"depart":world.sim.day,"due":world.sim.day+5,"delay":0,"food":25.0,"wood":18.0,"cash":20.0}
 next_id+=1
 voyages.append(row)
 record("Spedizione di %s verso %s."%[port_name(clan),world.REGION_NAMES[region]])
 return true

func place_order(seller:int,buyer:int,good:String,amount:float)->bool:
 if not enabled or seller==buyer or not GOODS.has(good) or voyages.size()>=8:return false
 if port_population(seller)<=0 or port_population(buyer)<=0:return false
 if port_clan(seller)!=port_clan(buyer) and world.sim.peace<45:return false
 var quantity=minf(amount,balance(seller,good))
 var unit=(price(seller,good)+price(buyer,good))*.5
 quantity=minf(quantity,balance(buyer,"cash")/maxf(.1,unit))
 quantity=floorf(quantity*10)/10
 if quantity<1:return false
 var cost=quantity*unit
 change(seller,good,-quantity)
 change(buyer,"cash",-cost)
 voyages.append({"id":next_id,"kind":"trade","seller":seller,"buyer":buyer,"good":good,"amount":quantity,"cost":cost,"unit":unit,"depart":world.sim.day,"due":world.sim.day+4,"delay":0})
 next_id+=1
 record("%s vende %.1f %s a %s (%.1f monete in deposito)."%[port_name(seller),quantity,LABELS[good],port_name(buyer),cost])
 return true

func settle(row:Dictionary):
 if row.kind=="settle":
  var region=int(row.region)
  var clan=int(row.seller)
  var founders:Array=row.crew
  var c={"id":region+1,"region":region,"clan":clan,"name":str(world.REGION_NAMES[region]),"population":founders.size(),"founders":founders,"food":float(row.food),"wood":float(row.wood),"cash":float(row.cash),"stone":0.0,"tools":0.0,"houses":1,"age":0,"births":0,"deaths":0,"prosperity":50.0}
  life.migrate(c)
  colonies.append(c)
  for site in world.discovery_sites:
   if str(site.name)==str(world.REGION_NAMES[region]):site.found=true
  if is_instance_valid(world.discovery_root):world.rebuild_discoveries()
  record("Nasce la colonia "+str(c.name)+".")
 else:
  var seller=int(row.seller)
  var buyer=int(row.buyer)
  if port_population(buyer)>0 and port_population(seller)>0:
   change(buyer,str(row.good),float(row.amount))
   change(seller,"cash",float(row.cost))
   turnover+=float(row.cost)
   completed+=1
   record("Nave arrivata a "+port_name(buyer)+": pagamento regolato.")
  else:
   # Failed delivery returns stock and refunds escrow, even to a dormant port.
   change(seller,str(row.good),float(row.amount))
   change(buyer,"cash",float(row.cost))
   failed+=1
   record("Ordine annullato e deposito restituito.")
 voyages.erase(row)

func daily():
 if not enabled:return
 for v in voyages.duplicate():
  if world.sim.day<int(v.due):continue
  if float(route_for(v).length)<=.01:
   v.due=int(v.due)+1
   delayed+=1
   continue
  if world.sim.weather_name=="Pioggia" and int(v.delay)<2:
   v.due=int(v.due)+1
   v.delay=int(v.delay)+1
   delayed+=1
   continue
  settle(v)
 for c in colonies:life.daily(c)
 finance.daily()
 industry.daily()
 if world.sim.day%10==0:
  for i in range(2):recruit(i,i+1)
 if world.sim.day%3==0:match_market()
 sync_visuals()

func match_market():
 var ports=[0,1]
 for c in colonies:
  if int(c.population)>0:ports.append(int(c.id))
 for buyer in ports:
  for good in GOODS:
   if balance(buyer,good)>target(buyer,good)*.75:continue
   if voyages.any(func(v):return v.kind=="trade" and int(v.buyer)==int(buyer) and str(v.good)==good):continue
   var best=-1
   var surplus=0.0
   for seller in ports:
    if seller==buyer:continue
    if port_clan(seller)!=port_clan(buyer) and world.sim.peace<45:continue
    var excess=balance(seller,good)-target(seller,good)
    if excess>surplus:surplus=excess;best=int(seller)
   if best>=0:place_order(best,int(buyer),good,minf(12,minf(surplus,target(buyer,good)-balance(buyer,good))))

func port_region(id:int)->int:
 if id<2:return id+1
 return int(colony(id).get("region",1))

func shore(region:int,outer:bool)->Vector3:
 # Select points on the water corridor rather than teleport over land.
 var pt:Vector2=world.REGION_POINTS[region]
 var direction=pt.normalized()
 var begin=direction*12
 var end=pt
 var samples=[]
 for i in range(81):
  var q=begin.lerp(end,float(i)/80)
  if world.height_at(q.x,q.y)<world.SEA-.1:samples.append(q)
 if samples.is_empty():return Vector3(pt.x,world.SEA+.12,pt.y)
 var p:Vector2=samples.back() if outer else samples.front()
 return Vector3(p.x,world.SEA+.12,p.y)

func endpoints(row:Dictionary)->Array:
 var seller=int(row.seller)
 var origin=shore(port_region(seller),seller>=2)
 var destination=shore(int(row.region),true) if row.kind=="settle" else shore(port_region(int(row.buyer)),int(row.buyer)>=2)
 return [origin,destination]

func rebuild_sea_grid():
 sea_revision=int(world.terrain_revision)
 routes.clear()
 sea_grid.region=Rect2i(-26,-26,53,53)
 sea_grid.cell_size=Vector2(2,2)
 sea_grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 sea_grid.update()
 sea_grid.fill_solid_region(sea_grid.region,false)
 for x in range(-26,27):
  for z in range(-26,27):
   if world.height_at(x*2,z*2)>world.SEA-.20:sea_grid.set_point_solid(Vector2i(x,z))

func nearest_water(p:Vector3)->Vector2i:
 var best=Vector2i(999,999)
 var score=INF
 for x in range(roundi(p.x/2)-4,roundi(p.x/2)+5):
  for z in range(roundi(p.z/2)-4,roundi(p.z/2)+5):
   var cell=Vector2i(x,z)
   if not sea_grid.region.has_point(cell) or sea_grid.is_point_solid(cell):continue
   var d=Vector2(x*2-p.x,z*2-p.z).length_squared()
   if d<score:score=d;best=cell
 return best

func route_for(row:Dictionary)->Dictionary:
 if sea_revision!=int(world.terrain_revision):rebuild_sea_grid()
 var id=int(row.id)
 if routes.has(id):return routes[id]
 var ends=endpoints(row)
 var start=nearest_water(ends[0])
 var finish=nearest_water(ends[1])
 var points=[]
 var length=0.0
 if sea_grid.region.has_point(start) and sea_grid.region.has_point(finish):
  for cell in sea_grid.get_id_path(start,finish):
   var p=Vector3(cell.x*2,world.SEA+.12,cell.y*2)
   if not points.is_empty():length+=p.distance_to(points.back())
   points.append(p)
 if points.is_empty():points.append(ends[0])
 var route={"points":points,"length":length}
 routes[id]=route
 return route

func ship_position(row:Dictionary,day_fraction:float)->Vector3:
 var route=route_for(row)
 var points:Array=route.points
 var progress=clampf((day_fraction-float(row.depart))/maxf(1,float(row.due)-float(row.depart)),0,1)
 var remaining=float(route.length)*progress
 for i in range(1,points.size()):
  var a:Vector3=points[i-1]
  var b:Vector3=points[i]
  var length=a.distance_to(b)
  if remaining<=length:return a.lerp(b,remaining/maxf(.001,length))
  remaining-=length
 return points.back()

func make_ship()->Node3D:
 var n=Node3D.new()
 root.add_child(n)
 world.block(n,Color("68462c"),Vector3(0,.08,0),Vector3(.74,.28,1.65))
 world.cone(n,Color("996c42"),Vector3(0,.18,.60),.38,.54,.07,5).rotation.x=PI*.5
 world.block(n,Color("bb9669"),Vector3(0,.26,0),Vector3(.64,.08,1.35))
 world.block(n,Color("654b36"),Vector3(0,.78,0),Vector3(.065,1.14,.065))
 world.block(n,Color("f0e2b8"),Vector3(0,.92,.04),Vector3(.78,.70,.055))
 return n

func rebuild_visuals(parent:Node3D):
 root=parent
 fleet.clear()
 colony_nodes.clear()
 life.rebuild(parent)
 industry.rebuild(parent)
 routes.clear()
 sea_revision=-1
 if not enabled:return
 sync_visuals()

func sync_visuals():
 if not enabled or not is_instance_valid(root):return
 for id in fleet.keys():
  if not voyages.any(func(v):return int(v.id)==int(id)):
   fleet[id].queue_free()
   fleet.erase(id)
   routes.erase(id)
 for row in voyages:
  var id=int(row.id)
  if not fleet.has(id):fleet[id]=make_ship()
 for c in colonies:
  var id=int(c.id)
  var key=int(c.houses)*100+int(c.population)
  if colony_nodes.has(id) and int(colony_nodes[id].key)==key:continue
  if colony_nodes.has(id):colony_nodes[id].node.queue_free()
  var n=Node3D.new()
  root.add_child(n)
  var pt:Vector2=world.REGION_POINTS[int(c.region)]
  n.position=world.ground(pt.x,pt.y)
  var tint=Color("6fae9f") if int(c.clan)==0 else Color("d6a36f")
  for i in range(int(c.houses)):
   var angle=i*2.4
   var offset=Vector3(cos(angle),0,sin(angle))*sqrt(float(i))*1.3
   world.block(n,Color("a68b69"),offset+Vector3.UP*.45,Vector3(1.0,.9,.82))
   world.cone(n,tint,offset+Vector3.UP*1.12,.75,.56,.05,4).rotation.y=PI*.25
  var label=Label3D.new()
  n.add_child(label)
  label.position.y=2.1
  label.text=str(c.name)+" · "+str(c.population)
  label.font_size=28
  label.pixel_size=.009
  label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  colony_nodes[id]={"node":n,"key":key}
 life.sync()

func animate(day_fraction:float,clock:float):
 if not enabled:return
 for row in voyages:
  var id=int(row.id)
  if not fleet.has(id) or not is_instance_valid(fleet[id]):continue
  var n:Node3D=fleet[id]
  var pos=ship_position(row,day_fraction)
  var future=ship_position(row,day_fraction+.05)
  var dir=future-pos
  var water=world.ocean_dynamics
  n.position=pos+Vector3.UP*(sin(clock*2.1+id)*.055+water.surface_at(pos))
  var current:Vector3=water.current(pos)
  n.position+=Vector3(current.x,0,current.z)*.12
  if dir.length()>.001:n.rotation.y=atan2(dir.x,dir.z)
  n.rotation.z=sin(clock*1.7+id)*.08
  n.rotation.x=cos(clock*1.3+id)*.04

func report()->String:
 if not enabled:return "Il mercato marittimo è disponibile nella modalità Continenti."
 var lines=["MERCATO MARITTIMO","Navi: %d · Consegne: %d · Ritardi: %d"%[voyages.size(),completed,delayed],"Volume: %.1f monete · Ordini annullati: %d"%[turnover,failed],""]
 var ports=[0,1]
 for c in colonies:ports.append(int(c.id))
 for id in ports:
  lines.append("%s · %d abitanti · %.1f monete"%[port_name(id),port_population(id),balance(id,"cash")])
  for good in GOODS:lines.append("  %s %.1f · prezzo %.1f"%[LABELS[good],balance(id,good),price(id,good)])
  lines.append("")
 for row in voyages:lines.append("Nave %d · %s · arrivo G%d"%[int(row.id),"Coloni" if row.kind=="settle" else LABELS[row.good],int(row.due)])
 lines.append("")
 for entry in history.slice(0,8):lines.append(entry)
 lines.append(finance.report())
 lines.append(industry.report())
 for c in colonies:lines.append(life.report(c))
 return "\n".join(lines)


func damage_colonies(p:Vector3,radius:float,damage:float,kind:String):
 if not enabled:return
 for c in colonies:
  var point:Vector2=world.REGION_POINTS[int(c.region)]
  var dist=Vector2(p.x,p.z).distance_to(point)
  if dist>radius+2.0:continue
  var strength=clampf(damage/100.0,0,1)*clampf(1.0-dist/maxf(1,radius+2),0,1)
  var lost=life.damage(c,p,radius,damage)
  c.food=maxf(0,float(c.food)*(1.0-strength*.5))
  c.wood=maxf(0,float(c.wood)*(1.0-strength*.35))
  if strength>.5:c.houses=maxi(0,int(c.houses)-1)
  c.prosperity=maxf(0,float(c.prosperity)-strength*35)
  record("%s colpisce la colonia %s: %d vittime."%[kind,c.name,lost])
 sync_visuals()
