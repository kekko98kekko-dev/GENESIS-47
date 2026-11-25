extends RefCounted
# Independent colonies, sea transport and double-entry trade. Simulation is daily;
# graphical ships interpolate between departure and arrival.
const GOODS=["food","wood","stone","tools"]
const LABELS={"food":"Cibo","wood":"Legna","stone":"Pietra","tools":"Utensili"}
const BASE={"food":2.0,"wood":3.0,"stone":4.0,"tools":8.0}
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

func export_state()->Dictionary:
 return {"enabled":enabled,"colonies":colonies,"voyages":voyages,"accounts":accounts,"history":history,"next_id":next_id,"completed":completed,"delayed":delayed,"failed":failed,"turnover":turnover}

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
 return 1.0

func price(id:int,good:String)->float:
 var ratio=balance(id,good)/target(id,good)
 return snappedf(float(BASE[good])*clampf(1.65-ratio*.55,.45,2.5),.1)

func record(message:String):
 history.push_front("G%d · %s"%[world.sim.day,message])
 if history.size()>40:history.pop_back()
 world.sim.log_event(message)

func work_completed(clan:int,kind:String):
 if not enabled:return
 if kind=="gather":change(clan,"stone",.55)
 if kind=="craft":change(clan,"tools",1.0)

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
  crew.append({"id":int(a.id),"name":str(a.name),"age":float(a.age),"genes":a.genes.duplicate()})
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
 if seller<2 and buyer<2:return false
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
  if world.sim.weather_name=="Pioggia" and int(v.delay)<2:
   v.due=int(v.due)+1
   v.delay=int(v.delay)+1
   delayed+=1
   continue
  settle(v)
 for c in colonies:
  c.age=int(c.age)+1
  var n=int(c.population)
  if n<=0:continue
  var productivity=.9+minf(.5,float(c.tools)*.05)
  if world.sim.weather_name=="Siccità":productivity*=.65
  c.food=minf(500,float(c.food)+n*(productivity-.70))
  c.wood=minf(300,float(c.wood)+n*.30)
  c.stone=minf(250,float(c.stone)+n*.18)
  if int(c.age)%7==0 and float(c.wood)>=3 and float(c.stone)>=2:
   c.wood-=3
   c.stone-=2
   c.tools=minf(80,float(c.tools)+1)
  if int(c.age)%10==0 and n>=int(c.houses)*3 and float(c.wood)>=12 and float(c.stone)>=5:
   c.wood-=12
   c.stone-=5
   c.houses=mini(12,int(c.houses)+1)
  if int(c.age)%12==0 and n>=2 and n<int(c.houses)*4 and n<40 and float(c.food)>n*4:
   c.food-=3
   c.population=n+1
   c.births=int(c.births)+1
  if float(c.food)<.1 and int(c.age)%5==0:
   c.population=maxi(0,int(c.population)-1)
   c.deaths=int(c.deaths)+1
  c.prosperity=clampf(float(c.prosperity)+(1 if float(c.food)>n*2 else -3),0,100)
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
    if seller==buyer or (seller<2 and buyer<2):continue
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
 var from=shore(port_region(seller),seller>=2)
 var to=shore(int(row.region),true) if row.kind=="settle" else shore(port_region(int(row.buyer)),int(row.buyer)>=2)
 return [from,to]

func ship_position(row:Dictionary,day_fraction:float)->Vector3:
 var ends=endpoints(row)
 var a:Vector3=ends[0]
 var b:Vector3=ends[1]
 var progress=clampf((day_fraction-float(row.depart))/maxf(1,float(row.due)-float(row.depart)),0,1)
 if port_region(int(row.seller))==int(row.get("region",port_region(int(row.buyer)))):return a.lerp(b,progress)
 # Cross-regional voyages follow the outer coast via a sea waypoint.
 var mid=Vector3(-49,world.SEA+.12,49) if a.x<0 else Vector3(49,world.SEA+.12,-49)
 return a.lerp(mid,progress*2) if progress<.5 else mid.lerp(b,(progress-.5)*2)

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
 if not enabled:return
 sync_visuals()

func sync_visuals():
 if not enabled or not is_instance_valid(root):return
 for id in fleet.keys():
  if not voyages.any(func(v):return int(v.id)==int(id)):
   fleet[id].queue_free()
   fleet.erase(id)
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
  for i in range(mini(12,int(c.population))):
   var p=Vector3(cos(i*2.4)*2.4,.26,sin(i*2.4)*2.4)
   world.sphere(n,tint,p,Vector3(.23,.42,.23))
   world.sphere(n,Color("f0cfaa"),p+Vector3.UP*.27,Vector3(.22,.22,.22))
  var label=Label3D.new()
  n.add_child(label)
  label.position.y=2.1
  label.text=str(c.name)+" · "+str(c.population)
  label.font_size=28
  label.pixel_size=.009
  label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  colony_nodes[id]={"node":n,"key":key}

func animate(day_fraction:float,clock:float):
 if not enabled:return
 for row in voyages:
  var id=int(row.id)
  if not fleet.has(id) or not is_instance_valid(fleet[id]):continue
  var n:Node3D=fleet[id]
  var pos=ship_position(row,day_fraction)
  var future=ship_position(row,day_fraction+.05)
  var dir=future-pos
  n.position=pos+Vector3.UP*sin(clock*2.1+id)*.055
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
 return "\n".join(lines)
