extends RefCounted
# Cash-backed bank: deposits are liabilities, loans are assets, no cash creation.
var ocean
var banks:Dictionary={}
var ledger:Array=[]
var next_id=1

func setup(owner):
 ocean=owner
 banks={}
 ledger=[]
 next_id=1

func bank(port:int)->Dictionary:
 var key=str(port)
 if not banks.has(key):banks[key]={"reserve":0.0,"equity":0.0,"deposits":{},"loans":[],"defaults":0}
 if not banks[key].has("company_loans"):banks[key]["company_loans"]=[]
 return banks[key]

func entry(port:int,kind:String,amount:float,account:String):
 ledger.push_front({"id":next_id,"day":ocean.world.sim.day,"port":port,"kind":kind,"amount":amount,"account":account})
 next_id+=1
 if ledger.size()>160:ledger.pop_back()

func export_state()->Dictionary:
 return {"banks":banks,"ledger":ledger,"next_id":next_id}

func restore(d):
 if not d is Dictionary:return
 banks=d.get("banks",{})
 ledger=d.get("ledger",[])
 next_id=int(d.get("next_id",1))

func customer(port:int,id:int)->Dictionary:
 if port<2:
  var citizen=ocean.world.sim.find(id)
  return citizen if not citizen.is_empty() and int(citizen.clan)==port else {}
 var c=ocean.colony(port)
 for a in c.get("citizens",[]):
  if int(a.id)==id:return a
 return {}

func deposit(port:int,id:int,amount:float)->bool:
 var a=customer(port,id)
 if a.is_empty() or amount<=0 or float(a.coins)<amount:return false
 var b=bank(port)
 var key=str(id)
 a.coins-=amount
 b.reserve+=amount
 b.deposits[key]=float(b.deposits.get(key,0))+amount
 entry(port,"Deposito",amount,key)
 return true

func withdraw(port:int,id:int,amount:float)->bool:
 var a=customer(port,id)
 var b=bank(port)
 var key=str(id)
 if a.is_empty() or amount<=0 or float(b.deposits.get(key,0))<amount or float(b.reserve)<amount:return false
 b.deposits[key]-=amount
 b.reserve-=amount
 a.coins+=amount
 entry(port,"Prelievo",amount,key)
 return true

func capitalize(port:int,amount:float)->bool:
 if amount<=0 or ocean.balance(port,"cash")<amount:return false
 var b=bank(port)
 ocean.change(port,"cash",-amount)
 b.reserve+=amount
 b.equity+=amount
 entry(port,"Capitale",amount,"porto")
 return true

func lend(port:int,amount:float)->bool:
 var b=bank(port)
 var liabilities=0.0
 for value in b.deposits.values():liabilities+=float(value)
 if amount<=0 or float(b.reserve)-amount<maxf(2.0,liabilities*.35):return false
 if not b.loans.is_empty():return false
 b.reserve-=amount
 ocean.change(port,"cash",amount)
 b.loans.append({"principal":amount,"interest":amount*.05,"due":ocean.world.sim.day+15,"extensions":0})
 entry(port,"Prestito",amount,"porto")
 return true

func settle_depositor(port:int,id:int):
 var b=bank(port)
 var key=str(id)
 var liability=float(b.deposits.get(key,0))
 if liability<=0:return
 # Transfer deceased or emigrating customer's claim to port treasury;
 # preserve any illiquid claim until repayments restore the reserve.
 var paid=minf(liability,float(b.reserve))
 b.reserve-=paid
 ocean.change(port,"cash",paid)
 b.deposits[key]-=paid
 if float(b.deposits[key])>.001:
  b.deposits["estate"]=float(b.deposits.get("estate",0))+float(b.deposits[key])
 b.deposits.erase(key)

func daily():
 var ports=[0,1]
 for c in ocean.colonies:ports.append(int(c.id))
 for port in ports:
  var b=bank(port)
  if ocean.port_population(port)<=0:continue
  if float(b.equity)<15 and ocean.balance(port,"cash")>45:capitalize(port,15)
  var citizens=ocean.world.sim.people.filter(func(a):return int(a.clan)==port) if port<2 else ocean.colony(port).get("citizens",[])
  for a in citizens:
   if float(a.coins)>12:deposit(port,int(a.id),minf(2,float(a.coins)-10))
   elif float(a.coins)<2:withdraw(port,int(a.id),minf(2,float(b.deposits.get(str(a.id),0))))
  if float(b.deposits.get("estate",0))>0:
   var paid=minf(float(b.reserve),float(b.deposits.estate))
   b.reserve-=paid
   b.deposits.estate-=paid
   ocean.change(port,"cash",paid)
  for loan in b.loans.duplicate():
   if ocean.world.sim.day<int(loan.due):continue
   var owed=float(loan.principal)+float(loan.interest)
   var paid=minf(owed,ocean.balance(port,"cash"))
   if paid>0:
    ocean.change(port,"cash",-paid)
    b.reserve+=paid
    var interest_paid=minf(paid,float(loan.interest))
    loan.interest-=interest_paid
    loan.principal=maxf(0,float(loan.principal)-(paid-interest_paid))
    b.equity+=interest_paid
    entry(port,"Rata",paid,"porto")
   if float(loan.principal)+float(loan.interest)<.001:b.loans.erase(loan)
   else:
    loan.extensions+=1
    loan.due=ocean.world.sim.day+5
    if int(loan.extensions)>=4:
     b.equity-=float(loan.principal)
     b.defaults+=1
     b.loans.erase(loan)
     entry(port,"Insolvenza",float(loan.principal),"porto")
  if ocean.balance(port,"cash")<8 and b.loans.is_empty():lend(port,10)
  for loan in b.company_loans.duplicate():
   if ocean.world.sim.day>=int(loan.due):repay_company(port,loan,false)

func balance_sheet(port:int)->Dictionary:
 var b=bank(port)
 var deposits=0.0
 var loans=0.0
 for value in b.deposits.values():deposits+=float(value)
 for row in b.loans:loans+=float(row.principal)
 for row in b.company_loans:loans+=float(row.principal)
 return {"assets":float(b.reserve)+loans,"liabilities":deposits,"equity":float(b.equity),"reserve":float(b.reserve),"loans":loans,"defaults":int(b.defaults)}

func report()->String:
 var lines=["BANCHE E CONTABILITÀ"]
 for key in banks:
  var s=balance_sheet(int(key))
  lines.append("%s · riserva %.1f · crediti %.1f\nDepositi %.1f · patrimonio %.1f · insolvenze %d"%[ocean.port_name(int(key)),s.reserve,s.loans,s.liabilities,s.equity,s.defaults])
 for row in ledger.slice(0,8):lines.append("G%d · %s · %s %.2f"%[int(row.day),ocean.port_name(int(row.port)),row.kind,float(row.amount)])
 return "\n".join(lines)


func lend_company(port:int,id:int,amount:float)->bool:
 var b=bank(port)
 var f=ocean.industry.find(id)
 if f.is_empty() or not f.active or amount<=0:return false
 if b.company_loans.any(func(row):return int(row.company)==id):return false
 var liabilities=0.0
 for value in b.deposits.values():liabilities+=float(value)
 if float(b.reserve)-amount<maxf(2,liabilities*.50):return false
 b.reserve-=amount
 f.cash+=amount
 b.company_loans.append({"company":id,"principal":amount,"interest":amount*.06,"due":ocean.world.sim.day+12,"extensions":0})
 entry(port,"Credito impresa",amount,str(id))
 return true

func repay_company(port:int,loan:Dictionary,liquidating:bool):
 var b=bank(port)
 var f=ocean.industry.find(int(loan.company))
 var amount=0.0
 if not f.is_empty():amount=minf(float(f.cash),float(loan.principal)+float(loan.interest))
 if amount>0:
  f.cash-=amount
  b.reserve+=amount
  var interest_paid=minf(amount,float(loan.interest))
  loan.interest-=interest_paid
  loan.principal=maxf(0,float(loan.principal)-amount+interest_paid)
  b.equity+=interest_paid
  f.cost+=interest_paid
  entry(port,"Rata impresa",amount,str(loan.company))
 if float(loan.principal)+float(loan.interest)<.001:
  b.company_loans.erase(loan)
  return
 loan.extensions=int(loan.extensions)+1
 loan.due=ocean.world.sim.day+5
 if liquidating or int(loan.extensions)>=4:
  b.equity-=float(loan.principal)
  b.defaults+=1
  b.company_loans.erase(loan)
  entry(port,"Insolvenza impresa",float(loan.principal),str(loan.company))

func liquidate_company(port:int,id:int):
 var b=bank(port)
 for loan in b.company_loans.duplicate():
  if int(loan.company)==id:repay_company(port,loan,true)
