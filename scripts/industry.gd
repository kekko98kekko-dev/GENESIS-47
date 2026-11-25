extends RefCounted
# Companies own cash and stock. Inputs and output cross the port inventory
# through priced purchases/sales; work credits originate in completed tasks.
const RECIPES={
 "mill":{"label":"Mulino","input":{"food":3.0},"output":"flour","quantity":2.0,"labor":1.0,"task":["farm","craft"]},
 "bakery":{"label":"Forno","input":{"flour":2.0,"wood":.5},"output":"bread","quantity":3.0,"labor":1.0,"task":["craft","farm"]},
 "sawmill":{"label":"Segheria","input":{"wood":3.0},"output":"planks","quantity":2.0,"labor":1.0,"task":["gather","craft"]},
 "kiln":{"label":"Fornace","input":{"stone":3.0,"wood":1.0},"output":"bricks","quantity":2.0,"labor":1.0,"task":["mine","gather","craft"]},
 "forge":{"label":"Fucina","input":{"ore":2.0,"wood":1.0},"output":"metal","quantity":1.5,"labor":1.0,"task":["craft","mine"]},
 "workshop":{"label":"Officina","input":{"metal":1.0,"planks":1.0},"output":"tools","quantity":2.0,"labor":2.0,"task":["craft","build","house"]},
 "mechanics":{"label":"Meccanica","input":{"metal":2.0,"tools":1.0},"output":"machines","quantity":1.0,"labor":2.0,"task":["craft","research"]}}
var ocean
var companies:Array=[]
var ledger:Array=[]
var contracts:Array=[]
var next_id=1
var next_contract=1
var batches=0
var taxes=0.0
var wages=0.0
var root:Node3D
var nodes:Dictionary={}
var jobs:Dictionary={}
var delivered_units=0.0
var produced_units=0.0

func setup(owner):
 ocean=owner
 companies=[]
 ledger=[]
 contracts=[]
 next_id=1
 next_contract=1
 batches=0
 taxes=0.0
 wages=0.0
 nodes.clear()
 jobs={}
 delivered_units=0.0
 produced_units=0.0

func export_state()->Dictionary:
 return {"companies":companies,"ledger":ledger,"contracts":contracts,"next_id":next_id,"next_contract":next_contract,"batches":batches,"taxes":taxes,"wages":wages,"jobs":jobs,"delivered_units":delivered_units,"produced_units":produced_units}

func restore(d):
 if not d is Dictionary:return
 companies=d.get("companies",[])
 contracts=d.get("contracts",[])
 ledger=d.get("ledger",[])
 next_id=int(d.get("next_id",1))
 next_contract=int(d.get("next_contract",1))
 batches=int(d.get("batches",0))
 taxes=float(d.get("taxes",0))
 wages=float(d.get("wages",0))
 jobs=d.get("jobs",{})
 delivered_units=float(d.get("delivered_units",0))
 produced_units=float(d.get("produced_units",0))
 for job in jobs.values():job["revision"]=-1

func log_entry(f:Dictionary,kind:String,amount:float,good=""):
 ledger.push_front({"day":ocean.world.sim.day,"company":int(f.id),"kind":kind,"amount":amount,"good":good})
 if ledger.size()>200:ledger.pop_back()

func find(id:int)->Dictionary:
 for f in companies:
  if int(f.id)==id:return f
 return {}

func population(port:int)->Array:
 if port<2:return ocean.world.sim.people.filter(func(a):return int(a.clan)==port)
 return ocean.colony(port).get("citizens",[])

func create_company(port:int,recipe:String,capital:float,founder:int=-1)->bool:
 if not ocean.enabled or not RECIPES.has(recipe) or capital<12:return false
 var owner=ocean.finance.customer(port,founder) if founder>=0 else {}
 if founder>=0 and (owner.is_empty() or float(owner.coins)<capital):return false
 if founder<0 and ocean.balance(port,"cash")<capital:return false
 if ocean.port_population(port)<2:return false
 if companies.any(func(f):return int(f.port)==port and f.recipe==recipe and f.active):return false
 if founder>=0:owner.coins-=capital
 else:ocean.change(port,"cash",-capital)
 var f={"id":next_id,"port":port,"recipe":recipe,"name":str(RECIPES[recipe].label)+" "+str(next_id),"cash":capital,"stock":{},"employees":[],"labor":0.0,"active":true,"batches":0,"revenue":0.0,"cost":0.0,"tax":0.0,"wages":0.0,"idle_days":0,"founded":ocean.world.sim.day,"owner":founder,"capital":capital,"dividends":0.0}
 next_id+=1
 companies.append(f)
 log_entry(f,"Capitale",capital)
 hire(f)
 sync_visuals()
 return true

func hire(f:Dictionary):
 var eligible=population(int(f.port)).filter(func(a):return float(a.age)>=14 and float(a.health)>45)
 f.employees=[]
 for a in eligible:
  if companies.any(func(other):return other!=f and other.active and other.employees.has(int(a.id))):continue
  f.employees.append(int(a.id))
  if f.employees.size()>=3:break

func on_work(port:int,a:Dictionary,kind:String):
 for f in companies:
  if not f.active or int(f.port)!=port or not f.employees.has(int(a.id)):continue
  if not RECIPES[f.recipe].task.has(kind) or float(f.cash)<.8:continue
  # A completed matching task earns a funded processing wage and labor credit.
  f.cash-=.8
  a.coins+=.8
  f.wages+=.8
  f.cost+=.8
  wages+=.8
  f.labor=minf(12,float(f.labor)+1.0)
  log_entry(f,"Salario",.8)
  break

func buy(f:Dictionary,good:String,quantity:float)->bool:
 if quantity<=0:return false
 var port=int(f.port)
 var cost=quantity*ocean.price(port,good)
 if ocean.balance(port,good)+.0001<quantity or float(f.cash)+.0001<cost:return false
 ocean.change(port,good,-quantity)
 ocean.change(port,"cash",cost)
 f.cash-=cost
 f.stock[good]=float(f.stock.get(good,0))+quantity
 f.cost+=cost
 log_entry(f,"Acquisto",cost,good)
 return true

func sell(f:Dictionary,good:String,quantity:float)->bool:
 if quantity<=0 or float(f.stock.get(good,0))+.0001<quantity:return false
 var port=int(f.port)
 var gross=quantity*ocean.price(port,good)
 if ocean.balance(port,"cash")+.0001<gross:return false
 ocean.change(port,"cash",-gross)
 ocean.change(port,good,quantity)
 f.stock[good]-=quantity
 var tax=gross*.05
 ocean.change(port,"cash",tax)
 f.cash+=gross-tax
 f.tax+=tax
 f.revenue+=gross
 taxes+=tax
 log_entry(f,"Vendita",gross,good)
 return true

func produce(f:Dictionary)->bool:
 var recipe:Dictionary=RECIPES[f.recipe]
 if not f.active or float(f.labor)<float(recipe.labor):return false
 if float(f.stock.get(recipe.output,0))>=24:return false
 var missing={}
 var bill=0.0
 for good in recipe.input:
  var q=maxf(0,float(recipe.input[good])-float(f.stock.get(good,0)))
  if q<=.0001:continue
  if ocean.balance(int(f.port),good)+.0001<q:return false
  missing[good]=q
  bill+=q*ocean.price(int(f.port),good)
 if float(f.cash)+.0001<bill:return false
 for good in missing:
  if not buy(f,good,float(missing[good])):return false
 for good in recipe.input:f.stock[good]-=float(recipe.input[good])
 f.stock[recipe.output]=float(f.stock.get(recipe.output,0))+float(recipe.quantity)
 f.labor-=float(recipe.labor)
 f.batches+=1
 batches+=1
 log_entry(f,"Produzione",float(recipe.quantity),str(recipe.output))
 return true

func make_contract(seller:int,buyer:int,good:String,quantity:float)->bool:
 var a=find(seller)
 var b=find(buyer)
 if a.is_empty() or b.is_empty() or not a.active or not b.active or seller==buyer or int(a.port)!=int(b.port):return false
 if not ocean.GOODS.has(good) or quantity<=0 or float(a.stock.get(good,0))<quantity:return false
 var total=quantity*ocean.price(int(a.port),good)*.92
 if float(b.cash)<total:return false
 a.stock[good]-=quantity
 b.cash-=total
 contracts.append({"id":next_contract,"seller":seller,"buyer":buyer,"good":good,"quantity":quantity,"escrow":total,"due":ocean.world.sim.day+1})
 next_contract+=1
 return true

func settle_contract(row:Dictionary):
 var a=find(int(row.seller))
 var b=find(int(row.buyer))
 var good=str(row.good)
 if a.is_empty() or b.is_empty():return
 if a.active and b.active:
  b.stock[good]=float(b.stock.get(good,0))+float(row.quantity)
  a.cash+=float(row.escrow)
  a.revenue+=float(row.escrow)
  b.cost+=float(row.escrow)
  log_entry(a,"Contratto",float(row.escrow),good)
 else:
  if a.active:a.stock[good]=float(a.stock.get(good,0))+float(row.quantity)
  else:ocean.change(int(a.port),good,float(row.quantity))
  if b.active:b.cash+=float(row.escrow)
  else:ocean.change(int(b.port),"cash",float(row.escrow))
 contracts.erase(row)

func close(f:Dictionary):
 ocean.finance.liquidate_company(int(f.port),int(f.id))
 f.active=false
 for key in jobs.keys():
  if int(jobs[key].company)==int(f.id):cancel_job(key)
 for row in contracts.duplicate():
  if int(row.seller)==int(f.id) or int(row.buyer)==int(f.id):settle_contract(row)
 for good in f.stock:ocean.change(int(f.port),good,float(f.stock[good]))
 f.stock={}
 var owner=ocean.finance.customer(int(f.port),int(f.get("owner",-1)))
 if owner.is_empty():ocean.change(int(f.port),"cash",float(f.cash))
 else:owner.coins+=float(f.cash)
 f.cash=0.0
 f.employees=[]
 log_entry(f,"Liquidazione",0.0)

func daily():
 if not ocean.enabled:return
 for row in contracts.duplicate():
  if not bool(row.get("physical",false)) and ocean.world.sim.day>=int(row.due):settle_contract(row)
 var ports=[0,1]
 for c in ocean.colonies:ports.append(int(c.id))
 for port in ports:
  if ocean.port_population(port)<2:continue
  if ocean.world.sim.day%5==0:
   for recipe in RECIPES:
    if ocean.balance(port,"cash")<36:break
    if int(ocean.world.sim.villages[ocean.port_clan(port)].tech)<(4 if recipe in ["forge","mechanics"] else 2):continue
    var founder=-1
    for a in population(port):
     if float(a.age)>=18 and float(a.coins)>=30:founder=int(a.id);break
    if create_company(port,recipe,18.0,founder):break
 for f in companies:
  if not f.active:continue
  if ocean.world.sim.day%7==0:hire(f)
  f.idle_days+=1
  if float(f.cash)<5 and int(f.idle_days)>5:ocean.finance.lend_company(int(f.port),int(f.id),8)
  if ocean.world.sim.day%15==0:pay_dividend(f)
  if int(f.idle_days)>30 and float(f.cash)<1 and f.stock.values().all(func(q):return float(q)<.1):close(f)
 for key in jobs.keys():
  var job=jobs[key]
  var company=find(int(job.company))
  if company.is_empty() or not company.active or ocean.finance.customer(int(company.port),int(key)).is_empty():cancel_job(key)
 sync_visuals()

func cash_total()->float:
 var result=0.0
 for f in companies:result+=float(f.cash)
 for row in contracts:result+=float(row.escrow)
 return result

func rebuild(parent:Node3D):
 root=parent
 nodes.clear()
 sync_visuals()

func sync_visuals():
 if not is_instance_valid(root):return
 var w=ocean.world
 for f in companies:
  var id=int(f.id)
  if not f.active:
   if nodes.has(id):nodes[id].queue_free();nodes.erase(id)
   continue
  if nodes.has(id):continue
  var n=Node3D.new()
  root.add_child(n)
  var port=int(f.port)
  var center:Vector3=w.centers[port] if port<2 else w.ground(w.REGION_POINTS[ocean.port_region(port)].x,w.REGION_POINTS[ocean.port_region(port)].y)
  var angle=float(id)*2.39996
  var p=w.ground(center.x+cos(angle)*4,center.z+sin(angle)*4)
  n.position=p
  w.block(n,Color("8e7860"),Vector3(0,.55,0),Vector3(1.35,1.1,1.15))
  w.block(n,Color("56696b"),Vector3(0,1.15,0),Vector3(1.55,.18,1.35))
  w.block(n,Color("b69a82"),Vector3(.42,1.55,-.3),Vector3(.22,1,.22))
  var tag=Label3D.new()
  n.add_child(tag)
  tag.position.y=2.3
  tag.text=str(f.name)
  tag.font_size=25
  tag.pixel_size=.008
  tag.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  nodes[id]=n

func report()->String:
 var lines=["IMPRESE E FILIERE","Unità prodotte %.1f · Consegnate %.1f · Salari %.1f · Imposte %.1f"%[produced_units,delivered_units,wages,taxes],"Lavoratori in filiera: "+str(jobs.size())]
 for f in companies:
  var owner=ocean.finance.customer(int(f.port),int(f.get("owner",-1)))
  lines.append("%s · %s · %s\nProprietà %s · Cassa %.1f · Dipendenti %d\nRicavi %.1f · Costi %.1f · Dividendi %.1f\nScorte %s"%[f.name,ocean.port_name(int(f.port)),"Attiva" if f.active else "Liquidata",str(owner.get("name","Comunità")),float(f.cash),f.employees.size(),float(f.revenue),float(f.cost),float(f.get("dividends",0)),str(f.stock)])
 return "\n".join(lines)


func pay_dividend(f:Dictionary):
 var profit=float(f.revenue)-float(f.cost)-float(f.tax)-float(f.get("dividends",0))
 var amount=minf(maxf(0,profit*.2),maxf(0,float(f.cash)-20))
 if amount<.1:return
 var owner=ocean.finance.customer(int(f.port),int(f.get("owner",-1)))
 f.cash-=amount
 if owner.is_empty():ocean.change(int(f.port),"cash",amount)
 else:owner.coins+=amount
 f["dividends"]=float(f.get("dividends",0))+amount
 log_entry(f,"Dividendo",amount)


func cancel_job(key:String):
 if not jobs.has(key):return
 var job:Dictionary=jobs[key]
 var f=find(int(job.company))
 if job.has("contract"):
  var row=contract_by_id(int(job.contract))
  if not row.is_empty():refund_contract(row)
 if not f.is_empty():
  for good in job.get("cargo",{}):
   if f.active:f.stock[good]=float(f.stock.get(good,0))+float(job.cargo[good])
   else:ocean.change(int(f.port),good,float(job.cargo[good]))
 jobs.erase(key)

func warehouse(port:int)->Vector3:
 var w=ocean.world
 if port<2:return w.centers[port]
 var p:Vector2=w.REGION_POINTS[ocean.port_region(port)]
 return w.ground(p.x,p.y)

func factory(f:Dictionary)->Vector3:
 var node=nodes.get(int(f.id))
 if is_instance_valid(node):return node.position+Vector3(0,0,1)
 return warehouse(int(f.port))

func choose_job(port:int,a:Dictionary)->Dictionary:
 if float(a.age)<14 or float(a.hunger)>68 or float(a.fatigue)>68 or float(a.health)<50:return {}
 for f in companies:
  if not f.active or int(f.port)!=port or not f.employees.has(int(a.id)) or not nodes.has(int(f.id)):continue
  if jobs.values().any(func(j):return int(j.company)==int(f.id)):continue
  var recipe:Dictionary=RECIPES[f.recipe]
  var output=str(recipe.output)
  if float(f.stock.get(output,0))>=.99 and (not customer_firm(f,output).is_empty() or (ocean.balance(port,"cash")>=ocean.price(port,output) and ocean.balance(port,output)<ocean.target(port,output)*2)):
   return {"company":int(f.id),"stage":"output_pickup","cargo":{},"remaining":0.0,"path":[],"index":0,"revision":-1,"quantity":1.0}
  if float(f.stock.get(output,0))>=8 or float(f.cash)<.8:continue
  var ratio=1.0/float(recipe.quantity)
  var needed={}
  var cost=.8
  for good in recipe.input:
   var q=maxf(0,float(recipe.input[good])*ratio-float(f.stock.get(good,0)))
   if q>.0001:
    if ocean.balance(port,good)<q:cost=INF;break
    needed[good]=q
    cost+=q*ocean.price(port,good)
  if float(f.cash)<cost:continue
  return {"company":int(f.id),"stage":"warehouse" if not needed.is_empty() else "work","needed":needed,"cargo":{},"remaining":float(recipe.labor)*ratio*4.0,"path":[],"index":0,"revision":-1,"quantity":1.0}
 return {}

func set_stage(job:Dictionary,stage:String):
 job.stage=stage
 job.path=[]
 job.index=0
 job.revision=-1

# Return -1 for ordinary life, 0 for processing, 1 for walking.
func advance(port:int,a:Dictionary,node:Node3D,dt:float)->int:
 a.erase("industry_action")
 if not ocean.enabled or not is_instance_valid(node):return -1
 var key=str(int(a.id))
 if float(a.hunger)>82 or float(a.fatigue)>82 or float(a.health)<40:
  if jobs.has(key):jobs[key].revision=-1
  return -1
 if not jobs.has(key):
  var created=choose_job(port,a)
  if created.is_empty():return -1
  jobs[key]=created
 var job:Dictionary=jobs[key]
 var f=find(int(job.company))
 if f.is_empty() or not f.active or int(f.port)!=port:
  cancel_job(key)
  return -1
 var w=ocean.world
 var stage=str(job.stage)
 var destination=warehouse(port) if stage in ["warehouse","output_delivery"] else factory(f)
 if stage=="contract_delivery":
  var contract=contract_by_id(int(job.get("contract",-1)))
  if contract.is_empty():cancel_job(key);return -1
  var buyer=find(int(contract.buyer))
  if buyer.is_empty() or not buyer.active:cancel_job(key);return -1
  destination=factory(buyer)
 if int(job.revision)!=int(w.nav_version):
  job.path=[]
  var start:Vector2i=w.near_cell(node.position)
  var end:Vector2i=w.near_cell(destination)
  if w.nav_grid.region.has_point(start) and w.nav_grid.region.has_point(end):
   for cell in w.nav_grid.get_id_path(start,end):job.path.append([cell.x,cell.y])
  if job.path.is_empty():cancel_job(key);return -1
  job.index=0
  job.revision=int(w.nav_version)
 var budget=dt*2.7
 while int(job.index)<job.path.size() and budget>0:
  var cell=job.path[int(job.index)]
  var target:Vector3=w.ground(float(cell[0]),float(cell[1]))
  var diff=Vector3(target.x-node.position.x,0,target.z-node.position.z)
  var length=diff.length()
  if length>.01:node.rotation.y=lerp_angle(node.rotation.y,atan2(diff.x,diff.z),clampf(dt*7,0,1))
  if length>budget:
   var pos=node.position+diff.normalized()*budget
   node.position=w.ground(pos.x,pos.z)
   budget=0
  else:
   node.position=target
   budget-=length
   job.index+=1
 if int(job.index)<job.path.size():
  a["industry_action"]="deliver" if not job.cargo.is_empty() or stage=="contract_delivery" else "explore"
  a.task_stage="Trasporto industriale"
  return 1
 var recipe:Dictionary=RECIPES[f.recipe]
 var output=str(recipe.output)
 match stage:
  "warehouse":
   # Recheck availability and funds at pickup; transfers are exact.
   var bill=.8
   for good in job.needed:
    if ocean.balance(port,good)<float(job.needed[good]):cancel_job(key);return -1
    bill+=float(job.needed[good])*ocean.price(port,good)
   if float(f.cash)<bill:cancel_job(key);return -1
   for good in job.needed:
    var q=float(job.needed[good])
    var cost=q*ocean.price(port,good)
    ocean.change(port,good,-q)
    ocean.change(port,"cash",cost)
    f.cash-=cost
    f.cost+=cost
    job.cargo[good]=q
    log_entry(f,"Ritiro",cost,good)
   set_stage(job,"work")
  "work":
   for good in job.cargo:f.stock[good]=float(f.stock.get(good,0))+float(job.cargo[good])
   job.cargo={}
   a["industry_action"]="industry"
   a.task_stage="In corso"
   job.remaining=maxf(0,float(job.remaining)-dt)
   if job.remaining>0:return 0
   var ratio=1.0/float(recipe.quantity)
   for good in recipe.input:
    if float(f.stock.get(good,0))+.0001<float(recipe.input[good])*ratio:cancel_job(key);return -1
   if float(f.cash)<.8:cancel_job(key);return -1
   for good in recipe.input:f.stock[good]=maxf(0,float(f.stock[good])-float(recipe.input[good])*ratio)
   f.stock[output]=float(f.stock.get(output,0))+1.0
   f.cash-=.8
   f.wages+=.8
   f.cost+=.8
   wages+=.8
   a.coins+=.8
   a.tasks_done=int(a.tasks_done)+1
   f.idle_days=0
   produced_units+=1
   log_entry(f,"Unità prodotta",1,output)
   jobs.erase(key)
  "output_pickup":
   if float(f.stock.get(output,0))<1:cancel_job(key);return -1
   var buyer=customer_firm(f,output)
   if not buyer.is_empty() and make_contract(int(f.id),int(buyer.id),output,1.0):
    var contract:Dictionary=contracts.back()
    contract["physical"]=true
    job["contract"]=int(contract.id)
    set_stage(job,"contract_delivery")
   else:
    f.stock[output]-=1
    job.cargo[output]=1.0
    set_stage(job,"output_delivery")
  "contract_delivery":
   var contract=contract_by_id(int(job.get("contract",-1)))
   if contract.is_empty():cancel_job(key);return -1
   var q=float(contract.quantity)
   settle_contract(contract)
   delivered_units+=q
   jobs.erase(key)
  "output_delivery":
   # Sale occurs only after physical arrival at warehouse.
   var q=float(job.cargo.get(output,0))
   if q<=0:cancel_job(key);return -1
   f.stock[output]=float(f.stock.get(output,0))+q
   job.cargo={}
   if sell(f,output,q):delivered_units+=q
   jobs.erase(key)
 a["industry_action"]="industry"
 a.task_stage="In corso"
 return 0


func customer_firm(f:Dictionary,good:String)->Dictionary:
 for other in companies:
  if not other.active or int(other.id)==int(f.id) or int(other.port)!=int(f.port):continue
  var inputs:Dictionary=RECIPES[other.recipe].input
  if not inputs.has(good):continue
  if float(other.stock.get(good,0))>=float(inputs[good])*2:continue
  if float(other.cash)<ocean.price(int(f.port),good)*.92:continue
  return other
 return {}

func contract_by_id(id:int)->Dictionary:
 for row in contracts:
  if int(row.id)==id:return row
 return {}

func refund_contract(row:Dictionary):
 var seller=find(int(row.seller))
 var buyer=find(int(row.buyer))
 var good=str(row.good)
 if not seller.is_empty():
  if seller.active:seller.stock[good]=float(seller.stock.get(good,0))+float(row.quantity)
  else:ocean.change(int(seller.port),good,float(row.quantity))
 if not buyer.is_empty():
  if buyer.active:buyer.cash+=float(row.escrow)
  else:ocean.change(int(buyer.port),"cash",float(row.escrow))
 contracts.erase(row)
