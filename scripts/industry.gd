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

func export_state()->Dictionary:
 return {"companies":companies,"ledger":ledger,"contracts":contracts,"next_id":next_id,"next_contract":next_contract,"batches":batches,"taxes":taxes,"wages":wages}

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
  if ocean.world.sim.day>=int(row.due):settle_contract(row)
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
  if produce(f):f.idle_days=0
  else:f.idle_days+=1
  var good=str(RECIPES[f.recipe].output)
  var available=float(f.stock.get(good,0))
  for other in companies:
   if available<1:break
   if not other.active or int(other.port)!=int(f.port) or other.id==f.id:continue
   var needs:Dictionary=RECIPES[other.recipe].input
   if not needs.has(good):continue
   var q=minf(available,maxf(0,float(needs[good])*2-float(other.stock.get(good,0))))
   if q>=1 and make_contract(int(f.id),int(other.id),good,q):available-=q
  if available>0 and ocean.balance(int(f.port),good)<ocean.target(int(f.port),good)*2:sell(f,good,minf(available,4))
  if float(f.cash)<5 and int(f.idle_days)>5:ocean.finance.lend_company(int(f.port),int(f.id),8)
  if ocean.world.sim.day%15==0:pay_dividend(f)
  if int(f.idle_days)>30 and float(f.cash)<1 and f.stock.values().all(func(q):return float(q)<.1):close(f)
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
 var lines=["IMPRESE E FILIERE","Lotti %d · Salari %.1f · Imposte %.1f · Contratti aperti %d"%[batches,wages,taxes,contracts.size()]]
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
