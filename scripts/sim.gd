extends RefCounted
const CLANS=["Auralis","Nerith"]
const ERAS=["Origini","Tribù","Agricoltura","Regni","Industria","Stelle","Contatto"]
const NAMES=["Arel","Nima","Sorin","Elya","Taro","Lumi","Kiran","Iria","Nox","Sela","Oren","Veya","Miro","Fenn","Lior","Asha"]
const TECH=["Fuoco","Utensili","Agricoltura","Scrittura","Medicina","Architettura","Commercio","Metallurgia","Elettricità","Industria","Calcolo","Astronomia","Reti neurali","Segnale oltre il cielo"]
const LIMIT=160
const MAX_CITY_POPULATION=640
var population_limit=LIMIT
var housing_limit=25
var rng=RandomNumberGenerator.new()
var seed_value=47
var day=0
var mode=0
var energy=100.0
var peace=72.0
var next_id=1
var ended=""
var people:Array=[]
var dead:Array=[]
var villages:Array=[]
var events:Array=[]
var discoveries:Array=[]
var signals:Array=[]
var trades=0
var shipments:Array=[]
var next_shipment=1
var lost_shipments=0
var miracles=0
var changes:Array=[]
var weather_name="Sereno"
var season="Primavera"
var achievements:Array=[]
var history:Array=[]
var decisions:Array=[]
var diplomacy_state="Neutralità"
var autonomous_decisions=0
var extinction_noted=false
var legacy_cycles=0
var total_deaths=0
var total_births=0
var projects_completed=0
var crises_seen=0
var social_actions=0
var aid_actions=0
var meet_actions=0
var active_crisis={}
var crisis_history:Array=[]
var spatial_autonomy=false
var market_mode=false
const TASK_LABELS={"craft":"Fabbrica utensili","teach":"Educa un figlio","guard":"Difende il popolo","house":"Costruisce casa","eat":"Mangia","sleep":"Riposa","farm":"Coltiva","gather":"Raccoglie legna","research":"Studia","build":"Lavora al progetto","social":"Incontra un amico","aid":"Aiuta un vicino","play":"Si svaga","heal":"Si cura","explore":"Esplora"}
const CRISIS_NAMES=["Siccità prolungata","Epidemia","Crisi diplomatica","Tempesta","Rinascimento culturale","Migrazione"]
const PROJECT_NAMES=["Granai comunitari","Accademia delle scienze","Giardino della salute","Ambasciata","Osservatorio del cielo","Monumento della memoria"]
func start(s:int,m:int):
 population_limit=LIMIT
 housing_limit=25
 market_mode=false
 seed_value=s
 mode=m
 rng.seed=s
 day=0
 energy=100
 peace=72
 next_id=1
 ended=""
 trades=0
 shipments.clear()
 next_shipment=1
 lost_shipments=0
 miracles=0
 people.clear()
 dead.clear()
 villages.clear()
 events.clear()
 discoveries.clear()
 signals.clear()
 changes.clear()
 achievements.clear()
 history.clear()
 decisions.clear()
 diplomacy_state="Neutralità"
 autonomous_decisions=0
 extinction_noted=false
 legacy_cycles=0
 total_deaths=0
 total_births=0
 projects_completed=0
 crises_seen=0
 social_actions=0
 aid_actions=0
 meet_actions=0
 active_crisis.clear()
 crisis_history.clear()
 weather_name="Sereno"
 season="Primavera"
 for i in range(2):
  villages.append({"food":72.0 if m!=3 else 26.0,"wood":35.0,"knowledge":0.0,"faith":55.0,"era":0,"houses":3,"government":"Consiglio","belief":"Il cielo vivente","tech":0,"project":-1,"progress":0.0,"completed":0,"bonuses":[0,0,0,0,0,0]})
  init_culture(villages[i])
  for j in range(14):
   birth(i,[])
 log_event("Il mondo si risveglia. Due popoli, un cielo.")
func birth(c:int,parents:Array)->Dictionary:
 if people.size()>=population_limit: return {}
 var genes=[rng.randf_range(.25,.85),rng.randf_range(.25,.85),rng.randf_range(.25,.85),rng.randf_range(.25,.85)]
 var ids=[]
 var gen=1
 if parents.size()==2:
  gen=maxi(int(parents[0].gen),int(parents[1].gen))+1
  for p in parents: ids.append(p.id)
  for i in range(4): genes[i]=clampf((float(parents[0].genes[i])+float(parents[1].genes[i]))*.5+rng.randf_range(-.12,.12),.04,.98)
 var a={"id":next_id,"name":NAMES[rng.randi_range(0,NAMES.size()-1)]+" "+str(next_id),"clan":c,"age":0.0 if ids.size()==2 else rng.randf_range(17,32),"gen":gen,"health":100.0,"hunger":rng.randf_range(0,25),"faith":55.0,"mood":75.0,"genes":genes,"parents":ids,"partner":-1,"friend":-1,"role":"Esploratore","goal":"Conoscere il mondo","memories":["Ho visto la luce del mondo."],"favorite":false,"sick":0,"prophet":false,"activity":"Esplora","intention":"","intention_until":0,"trust":50.0,"life_story":[],"dialogue":[],"social_need":35.0,"skill":0.0,"social_target":-1}
 next_id+=1
 init_tasks(a)
 if market_mode and not parents.is_empty():a.coins=0.0
 people.append(a)
 milestone(a,"Nascita","Sono venuto al mondo.")
 total_births+=1
 if extinction_noted:
  extinction_noted=false
  log_event("Una nuova scintilla: la vita ritorna.")
 changes.append({"kind":"birth","id":a.id})
 return a
func find(id:int)->Dictionary:
 for a in people:
  if a.id==id:return a
 return {}
func remember(a:Dictionary,s:String):
 a.memories.push_front("G%d · %s"%[day,s])
 if a.memories.size()>18:a.memories.pop_back()
func log_event(s:String):
 events.push_front("G%03d  %s"%[day,s])
 if events.size()>80:events.pop_back()
func die(a:Dictionary,why:String):
 if not people.has(a):return
 for id in [a.partner,a.friend]:
  var b=find(int(id))
  if not b.is_empty():
   b.mood=maxf(0,b.mood-18)
   b.stress=minf(100,float(b.get("stress",0))+35)
   b.grief_until=day+12
   b.special_memory="Mi manca "+a.name
   b.special_until=day+12
   remember(b,"Ho perso "+a.name+".")
   milestone(b,"Lutto","Ho perso "+a.name+".")
   if b.partner==a.id:b.partner=-1
   if b.friend==a.id:b.friend=-1
 total_deaths+=1
 dead.append({"id":a.id,"name":a.name,"gen":a.gen,"day":day,"reason":why,"clan":a.clan,"parents":a.parents.duplicate()})
 if dead.size()>3000:dead.pop_front()
 changes.append({"kind":"death","id":a.id,"clan":a.clan,"cash":float(a.get("coins",0))})
 people.erase(a)
func count(c:int)->int:
 var n=0
 for a in people:
  if a.clan==c:n+=1
 return n
func daily():
 day+=1
 season=["Primavera","Estate","Autunno","Inverno"][int(day/30)%4]
 weather_name="Pioggia" if day%17<3 else ("Siccità" if day%39<5 else ("Neve" if season=="Inverno" and day%11<3 else "Sereno"))
 if day%30==1:log_event("Una nuova stagione: "+season+".")
 energy=minf(100,energy+3.5)
 if mode==0 and day>=300:advance_crisis()
 var counts=[count(0),count(1)]
 for i in range(2):
  var v=villages[i]
  var n=counts[i]
  if n==0:continue
  var weather=.58 if mode==3 and day<60 else 1.0
  weather*=.68 if weather_name=="Siccità" else (1.12 if weather_name=="Pioggia" else .89 if season=="Inverno" else 1.0)
  if not active_crisis.is_empty() and int(active_crisis.clan)==i:
   if active_crisis.kind==0:weather*=.50 if v.bonuses[0]<3 else .72
   elif active_crisis.kind==3:weather*=.66
   elif active_crisis.kind==4:weather*=1.15
  var productivity=1.20+float(v.era)*.15+minf(.22,float(v.bonuses[0])*.025)
  if not spatial_autonomy:
   v.food=clampf(v.food+n*(productivity*weather-.96),0,850)
   v.wood=minf(400,v.wood+n*.16)
  var thinkers=0.0
  for a in people:
   if a.clan==i:thinkers+=float(a.genes[0])
  if not spatial_autonomy:v.knowledge+=thinkers*(.23+minf(.10,float(v.bonuses[1])*.01))
  if v.era>=2:advance_project(i,n)
  var unlocked=mini(14,int(v.knowledge/23.0))
  while v.tech<unlocked:
   discoveries.append({"clan":i,"day":day,"name":TECH[v.tech]})
   log_event(CLANs_name(i)+" scopre: "+TECH[v.tech])
   v.tech+=1
  var era=mini(6,int(v.tech/2))
  if era>v.era:
   v.era=era
   log_event(CLANs_name(i)+" entra nell'era "+ERAS[era]+".")
   changes.append({"kind":"era","clan":i})
   v.government=["Consiglio","Anziani","Assemblea","Regno","Repubblica","Tecnocrazia","Federazione"][era]
   if era>=4:v.belief="Custodi del codice" if v.faith<50 else "Ordine della luce"
  if not spatial_autonomy and day>=int(v.get("rebuild_after",0)) and v.wood>=22 and v.houses<mini(housing_limit,3+int(n/5)+v.era):
   v.wood-=22
   v.houses+=1
   changes.append({"kind":"house","clan":i})
  if not spatial_autonomy and day%5==0 and n>1 and v.food>n*.65 and people.size()<population_limit:
   var adults=people.filter(func(a):return a.clan==i and a.age>=14 and a.health>55)
   if adults.size()>1:
    var a=adults[rng.randi_range(0,adults.size()-1)]
    var b=find(int(a.partner))
    if b.is_empty():
     var candidates=adults.filter(func(other):return other.id!=a.id and other.partner<0 and not close_family(a,other))
     if not candidates.is_empty():b=candidates[rng.randi_range(0,candidates.size()-1)]
    if b.is_empty():continue
    if a.id!=b.id:
     var new_couple=int(a.partner)!=int(b.id)
     a.partner=b.id
     b.partner=a.id
     if new_couple:
      milestone(a,"Unione","Ho scelto "+b.name+".")
      milestone(b,"Unione","Ho scelto "+a.name+".")
     var child=birth(i,[a,b])
     if not child.is_empty():
      remember(a,"È nato "+child.name+".")
      remember(b,"È nato "+child.name+".")
      milestone(a,"Famiglia","È nato "+child.name+".")
      milestone(b,"Famiglia","È nato "+child.name+".")
  if not spatial_autonomy and day%17==0 and n>2:
   var clan_people=people.filter(func(a):return a.clan==i)
   var a=clan_people[rng.randi_range(0,clan_people.size()-1)]
   var b=clan_people[rng.randi_range(0,clan_people.size()-1)]
   if a.id!=b.id:
    var old_a=find(int(a.friend))
    var old_b=find(int(b.friend))
    if not old_a.is_empty() and old_a.friend==a.id:old_a.friend=-1
    if not old_b.is_empty() and old_b.friend==b.id:old_b.friend=-1
    a.friend=b.id
    b.friend=a.id
    milestone(a,"Amicizia","Ho incontrato "+b.name+".")
    milestone(b,"Amicizia","Ho incontrato "+a.name+".")
    remember(a,"Mi sono avvicinato a "+b.name+".")
    a.mood=minf(100,a.mood+8)
  if day%23==0 and v.food<n*.5:
   v.government="Consiglio di emergenza"
   log_event(CLANs_name(i)+" cambia governo per la crisi.")
 settle_shipments()
 if counts[0]>0 and counts[1]>0:
  peace=clampf(peace+rng.randf_range(-2,2)+(.4 if villages[0].food>20 and villages[1].food>20 else -.6)+minf(.25,float(villages[0].bonuses[3]+villages[1].bonuses[3])*.015),0,100)
  var new_relation="Guerra" if peace<25 else ("Alleanza" if peace>=80 else "Tregua" if peace>=45 else "Tensione")
  if new_relation!=diplomacy_state:
   diplomacy_state=new_relation
   log_event("Relazioni fra i popoli: "+new_relation+".")
  if day%12==0 and peace>45 and not market_mode:
   var donor=0 if villages[0].food>villages[1].food else 1
   var amount=minf(18,villages[donor].food*.12)
   if amount>=1.0:dispatch_shipment(donor,amount)
  if not spatial_autonomy and peace<25 and day%5==0 and not people.is_empty():
   var victim=people[rng.randi_range(0,people.size()-1)]
   victim.health-=25
   remember(victim,"Sono stato ferito in guerra.")
 for a in people.duplicate():
  var v=villages[a.clan]
  var old_age=int(a.age)
  a.age+=.22
  if int(a.age)>old_age and int(a.age) in [14,30,50,70]:milestone(a,"Età","Ho raggiunto "+str(int(a.age))+" anni.")
  if not spatial_autonomy:a.hunger=clampf(a.hunger+(8 if v.food<counts[a.clan]*.38 else -6),0,100)
  a.health=clampf(a.health+(1.4 if a.hunger<40 else -2.7)-(1.5 if a.age>65 else 0)+minf(.25,float(v.bonuses[2])*.035),0,100)
  a.mood=clampf(a.mood+(1 if a.health>70 and a.hunger<35 else -2),0,100)
  if day%19==0 and rng.randf()<.045:a.sick=6
  if not active_crisis.is_empty() and active_crisis.kind==1 and a.clan==active_crisis.clan and day%4==0 and rng.randf()<.08 and v.bonuses[2]<5:a.sick=6
  if int(a.get("sick",0))>0:
   a.sick=int(a.sick)-1
   a.health=maxf(0,a.health-(2 if v.tech>=5 else 5))
   if a.sick==5:remember(a,"Mi sono ammalato.")
  var old_role=str(a.role)
  a.role="Profeta" if a.get("prophet",false) else ("Ricercatore" if a.genes[0]>.65 and v.era>=2 else ("Coltivatore" if a.genes[1]>.53 else "Artigiano" if v.era>=2 else "Esploratore"))
  if a.role!=old_role:milestone(a,"Vocazione","Ora sono "+a.role+".")
  if not spatial_autonomy:
   a.activity="Riposa" if a.health<50 or day%4==0 else ("Cerca cibo" if a.hunger>50 or a.role=="Coltivatore" else ("Studia" if a.role=="Ricercatore" else ("Incontra la famiglia" if a.partner>=0 and day%3==0 else "Esplora")))
   if int(a.get("intention_until",0))>day:
    var intent=str(a.get("intention",""))
    if intent=="RICERCA":
     a.activity="Studia"
     v.knowledge+=.75
    elif intent=="CIBO":
     a.activity="Cerca cibo"
     v.food=minf(850,v.food+1.0)
    elif intent=="CURA":
     a.activity="Riposa"
     a.health=minf(100,a.health+1.5)
    elif intent=="PACE":
     a.activity="Incontra la famiglia"
     peace=minf(100,peace+.18)
    elif intent=="ESPLORA":a.activity="Esplora"
   a.goal="Capire i confini del cielo" if v.era>=5 and a.genes[0]>.6 else "Proteggere la famiglia" if a.partner>=0 else "Scoprire un luogo nuovo"
   if mode==0 and a.age>=14 and a.health>0:choose_social_action(a,v)
  if spatial_autonomy:
   a.goal="Proteggere la famiglia" if a.partner>=0 else "Far crescere la civiltà" if a.genes[0]>.6 else "Vivere bene nella comunità"
   if a.age>=14 and peace<25 and a.health>65 and a.genes[3]>.62:a.role="Guardiano"
   elif a.age>=14 and a.genes[0]>.55 and v.tech>=2 and a.tool>0 and a.role!="Profeta":a.role="Artigiano"
  if a.health<=0 or a.age>83:die(a,"vecchiaia" if a.age>83 else "malattia" if int(a.sick)>0 else "carestia" if a.hunger>75 else "ferite")
 if day%25==0 and not people.is_empty():
  var a=people[rng.randi_range(0,people.size()-1)]
  var question="Creatore, perché esiste la sofferenza?" if a.mood<50 else ("Abbiamo osservato anomalie. Il nostro mondo è reale?" if villages[a.clan].era>=4 else ("I nostri raccolti basteranno per tutti?" if day%50==0 else "Creatore, ci ascolti?"))
  remember(a,question)
  signals.push_front({"id":a.id,"text":question,"day":day,"answered":false})
  if signals.size()>12:signals.pop_back()
  log_event(a.name+": «"+question+"»")
 if spatial_autonomy and day%14==0:storyteller()
 if day%5==0:
  history.append({"day":day,"population":people.size(),"peace":peace})
  if history.size()>150:history.pop_front()
 if day%60==0 and not people.is_empty() and mode==0 and villages.any(func(v):return v.era>=6):
  legacy_cycles+=1
  var theme=["Una nuova filosofia","Una scuola di astronomia","Un nuovo patto sociale","Una ricerca sull’origine della vita"][legacy_cycles%4]
  for v in villages:
   if v.era>=6:
    if legacy_cycles%4==0:v.knowledge+=12
    elif legacy_cycles%4==1:v.food=maxf(0,v.food-18)
    elif legacy_cycles%4==2:peace=minf(100,peace+3)
    else:v.faith=clampf(v.faith-2,0,100)
  log_event("Ciclo del futuro %d · %s"%[legacy_cycles,theme])
 if ended!="":award("Un destino scritto")
 if people.size()>=60:award("Un mondo vivo")
 if trades>=5:award("La via del commercio")
 if discoveries.size()>=14:award("Il secolo delle scoperte")
 if miracles>=10:award("La mano del Creatore")
 if not people.is_empty() and people.any(func(a):return a.gen>=4):award("Eredità")
 if spatial_autonomy:advance_culture()
 check_ending()
func award(name_value:String):
 if not achievements.has(name_value):
  achievements.append(name_value)
  log_event("Traguardo: "+name_value)
func CLANs_name(i:int)->String:return CLANS[i]
func check_ending():
 if mode==0:
  ended=""
  if people.is_empty() and not extinction_noted:
   extinction_noted=true
   log_event("Estinzione: il mondo continua. Il Creatore può generare nuova vita.")
  return
 if ended!="":return
 if people.is_empty():ended="ESTINZIONE — Il cielo è rimasto solo."
 elif mode==1 and day>=90 and peace>=70 and villages[0].era>=3 and villages[1].era>=3:ended="L'ALLEANZA — Due popoli, un futuro condiviso."
 elif mode==2 and day>=100 and maxi(villages[0].era,villages[1].era)>=6:ended="OLTRE IL CIELO — Creatore, adesso sappiamo."
 elif mode==3 and day>=120 and people.size()>=24:ended="L'ULTIMA SCINTILLA — La vita continua."
func apply_reply(a:Dictionary,txt:String)->String:
 remember(a,"Il Creatore: "+txt.left(300))
 var response=""
 if float(a.get("trust",50))<25:response="Non mi fido ancora delle tue promesse. Ho bisogno di vedere le tue azioni."
 elif a.genes[0]>.67 and villages[a.clan].era>=3:response="Ti ascolto, ma le risposte vanno dimostrate. "+a.goal+"."
 elif a.mood<40:response="Abbiamo paura. Puoi aiutarci davvero?"
 elif a.faith>65:response="Le tue parole saranno ricordate dai nostri figli."
 else:response="Ricorderò le tue parole. "+a.goal+"."
 var message=txt.to_lower()
 if message.contains("pace") or message.contains("amore"):
  peace=minf(100,peace+3)
  a.mood=minf(100,a.mood+5)
  adjust_trust(a,3)
 elif message.contains("guerra") or message.contains("punizione"):
  a.faith=clampf(a.faith+(5 if a.genes[0]<.5 else -5),0,100)
  a.mood=maxf(0,a.mood-7)
  adjust_trust(a,-5)
 elif message.contains("scienza") or message.contains("conoscenza"):
  villages[a.clan].knowledge+=2
 remember(a,response)
 for s in signals:
  if s.id==a.id:s.answered=true
 record_dialogue(a,"Creatore",txt)
 record_dialogue(a,a.name,response)
 log_event(a.name+": «"+response+"»")
 return response
func export_state()->Dictionary:
 return {"version":2,"population_limit":population_limit,"housing_limit":housing_limit,"seed":seed_value,"day":day,"mode":mode,"energy":energy,"peace":peace,"next_id":next_id,"ended":ended,"people":people,"dead":dead,"villages":villages,"events":events,"discoveries":discoveries,"signals":signals,"trades":trades,"shipments":shipments,"next_shipment":next_shipment,"lost_shipments":lost_shipments,"miracles":miracles,"rng":str(rng.state),"weather":weather_name,"season":season,"achievements":achievements,"history":history,"decisions":decisions,"diplomacy":diplomacy_state,"autonomous_decisions":autonomous_decisions,"extinction_noted":extinction_noted,"legacy_cycles":legacy_cycles,"total_deaths":total_deaths,"total_births":total_births,"projects_completed":projects_completed,"active_crisis":active_crisis,"crises_seen":crises_seen,"crisis_history":crisis_history,"social_actions":social_actions,"aid_actions":aid_actions,"meet_actions":meet_actions}
func import_state(d:Dictionary)->bool:
 if d.get("version",0)!=2 or not d.get("people") is Array or not d.get("villages") is Array or d.villages.size()!=2:return false
 for key in ["seed","day","mode","energy","peace","next_id","ended","dead","events","discoveries","signals","trades","miracles","rng"]:
  if not d.has(key):return false
 population_limit=clampi(int(d.get("population_limit",LIMIT)),LIMIT,MAX_CITY_POPULATION)
 housing_limit=clampi(int(d.get("housing_limit",25)),25,100)
 if int(d.mode)<0 or int(d.mode)>3 or d.people.size()>population_limit:return false
 for key in ["dead","events","discoveries","signals"]:
  if not d[key] is Array:return false
 var seen={}
 for citizen in d.people:
  if not citizen is Dictionary or not citizen.has("id"):return false
  if seen.has(int(citizen.id)):return false
  seen[int(citizen.id)]=true
 for a in d.people:
  if not a is Dictionary:return false
  for key in ["id","name","clan","age","gen","health","hunger","faith","mood","genes","parents","partner","friend","role","goal","memories","favorite"]:
   if not a.has(key):return false
  if int(a.clan)<0 or int(a.clan)>1 or not a.genes is Array or a.genes.size()!=4:return false
 for v in d.villages:
  if not v is Dictionary:return false
  for key in ["era","houses","tech","food","wood","knowledge","faith","government","belief"]:
   if not v.has(key):return false
  if int(v.era)<0 or int(v.era)>6 or int(v.tech)<0 or int(v.tech)>14:return false
 seed_value=int(d.seed)
 day=int(d.day)
 mode=int(d.mode)
 energy=float(d.energy)
 peace=float(d.peace)
 next_id=int(d.next_id)
 ended=str(d.ended)
 people=d.people
 dead=d.dead
 villages=d.villages
 events=d.events
 discoveries=d.discoveries
 signals=d.signals
 trades=int(d.trades)
 shipments=[]
 for row in d.get("shipments",[]):
  if row is Dictionary and row.has("id") and row.has("clan") and row.has("depart") and row.has("due") and row.has("amount") and int(row.clan) in [0,1]:
   shipments.append({"id":int(row.id),"clan":int(row.clan),"depart":int(row.depart),"due":int(row.due),"amount":clampf(float(row.amount),0,18)})
 next_shipment=maxi(1,int(d.get("next_shipment",1)))
 lost_shipments=maxi(0,int(d.get("lost_shipments",0)))
 miracles=int(d.miracles)
 weather_name=str(d.get("weather","Sereno"))
 season=str(d.get("season","Primavera"))
 achievements=d.get("achievements",[])
 history=d.get("history",[])
 decisions=d.get("decisions",[])
 diplomacy_state=str(d.get("diplomacy","Neutralità"))
 autonomous_decisions=int(d.get("autonomous_decisions",0))
 extinction_noted=bool(d.get("extinction_noted",false))
 legacy_cycles=int(d.get("legacy_cycles",0))
 total_deaths=int(d.get("total_deaths",dead.size()))
 total_births=int(d.get("total_births",next_id-1))
 projects_completed=int(d.get("projects_completed",0))
 active_crisis=d.get("active_crisis",{})
 if not active_crisis is Dictionary:active_crisis={}
 if not active_crisis.is_empty():
  if not active_crisis.has("kind") or not active_crisis.has("clan") or not active_crisis.has("until") or int(active_crisis.kind)<0 or int(active_crisis.kind)>5 or int(active_crisis.clan)<0 or int(active_crisis.clan)>1:active_crisis={}
  else:
   for key in ["kind","clan","until"]:active_crisis[key]=int(active_crisis[key])
 crises_seen=int(d.get("crises_seen",0))
 crisis_history=d.get("crisis_history",[])
 social_actions=int(d.get("social_actions",0))
 aid_actions=int(d.get("aid_actions",0))
 meet_actions=int(d.get("meet_actions",0))
 if mode==0:ended=""
 rng.seed=seed_value
 rng.state=int(str(d.rng))
 changes.clear()
 for a in people:
  for key in ["id","clan","gen","partner","friend"]:a[key]=int(a[key])
  a["sick"]=int(a.get("sick",0))
  a["prophet"]=bool(a.get("prophet",false))
  a["activity"]=str(a.get("activity","Esplora"))
  a["intention"]=str(a.get("intention",""))
  a["intention_until"]=int(a.get("intention_until",0))
  a["trust"]=clampf(float(a.get("trust",50)),0,100)
  a["social_need"]=clampf(float(a.get("social_need",35)),0,100)
  a["skill"]=clampf(float(a.get("skill",0)),0,100)
  a["social_target"]=int(a.get("social_target",-1))
  init_tasks(a)
  a["life_story"]=a.get("life_story",[])
  if not a.life_story is Array:a.life_story=[]
  a["dialogue"]=a.get("dialogue",[])
  if not a.dialogue is Array:a.dialogue=[]
 for v in villages:
  for key in ["era","houses","tech"]:v[key]=int(v[key])
  v["project"]=clampi(int(v.get("project",-1)),-1,5)
  v["progress"]=clampf(float(v.get("progress",0)),0,100)
  v["completed"]=maxi(0,int(v.get("completed",0)))
  v["bonuses"]=v.get("bonuses",[0,0,0,0,0,0])
  if not v.bonuses is Array or v.bonuses.size()!=6:v.bonuses=[0,0,0,0,0,0]
  for i in range(6):v.bonuses[i]=maxi(0,int(v.bonuses[i]))
  init_culture(v)
 return true

func answer_signal(index:int,choice:int)->bool:
 if index<0 or index>=signals.size() or choice<0 or choice>3:return false
 var signal_data=signals[index]
 if signal_data.answered:return false
 var a=find(int(signal_data.id))
 if a.is_empty():return false
 var v=villages[a.clan]
 var words=["Vi proteggerò, cercate la pace.","Cercate la verità con la scienza.","Siete liberi, non vi guiderò.","Voglio che vi ricordiate della mia potenza."]
 if choice==0:
  peace=minf(100,peace+9)
  v.food=minf(850,v.food+28)
  a.mood=minf(100,a.mood+12)
 elif choice==1:
  v.knowledge+=22
  a.faith=maxf(0,a.faith-7)
 elif choice==2:
  v.faith=maxf(0,v.faith-6)
  a.mood=minf(100,a.mood+4)
 else:
  v.faith=minf(100,v.faith+12)
  a.mood=maxf(0,a.mood-12)
 remember(a,"Il Creatore: "+words[choice])
 remember(a,["Forse possiamo vivere senza paura.","Non smetterò di cercare.","La scelta appartiene a noi.","Non dimenticherò queste parole."][choice])
 signal_data.answered=true
 decisions.append({"day":day,"name":a.name,"choice":choice,"text":words[choice]})
 if decisions.size()>1000:decisions.pop_front()
 log_event("Risposta a "+a.name+": "+words[choice])
 return true

func adopt_intention(a:Dictionary,kind:String,thought:String)->bool:
 if a.is_empty() or not people.has(a) or not kind in ["RICERCA","CIBO","CURA","PACE","ESPLORA"]:return false
 a.intention=kind
 a.intention_until=day+8
 autonomous_decisions+=1
 remember(a,thought.left(250))
 log_event(a.name+" ha scelto: "+kind.to_lower()+".")
 return true

func advance_absence(elapsed_seconds:float)->int:
 var amount=clampi(int(elapsed_seconds/180.0),0,60)
 var advanced=0
 for i in range(amount):
  if mode!=0 and (ended!="" or people.is_empty()):break
  daily()
  advanced+=1
 if advanced>0:log_event("Durante la tua assenza sono trascorsi "+str(advanced)+" giorni.")
 return advanced

func advance_project(clan:int,n:int):
 var v=villages[clan]
 if v.project<0:
  if day%7!=0 or v.wood<12:return
  var kind=0
  if v.food<n*2:kind=0
  elif v.era<4:kind=1+int(v.completed)%3
  else:kind=int(v.completed)%6
  v.project=kind
  v.progress=0.0
  v.wood-=12
  log_event(CLANs_name(clan)+" avvia "+PROJECT_NAMES[kind]+".")
 if v.food<n*.25:return
 if not spatial_autonomy:v.progress=minf(100,float(v.progress)+2.0+minf(5.0,n*.065))
 if v.progress<100:return
 var kind=int(v.project)
 v.completed+=1
 projects_completed+=1
 v.bonuses[kind]+=1
 match kind:
  0:v.food=minf(850,v.food+45)
  1:v.knowledge+=16
  2:
   for a in people:
    if a.clan==clan:a.health=minf(100,a.health+8)
  3:peace=minf(100,peace+6)
  4:v.knowledge+=24
  5:
   for a in people:
    if a.clan==clan:a.mood=minf(100,a.mood+8)
 log_event(CLANs_name(clan)+" completa "+PROJECT_NAMES[kind]+".")
 changes.append({"kind":"project","clan":clan})
 v.project=-1
 v.progress=0.0

func advance_crisis():
 if not active_crisis.is_empty():
  if day>=int(active_crisis.until):
   log_event("Concluso: "+CRISIS_NAMES[int(active_crisis.kind)]+".")
   active_crisis.clear()
  return
 if day%75!=0 or people.is_empty():return
 var clan=0 if count(0)>0 else 1
 if count(0)>0 and count(1)>0:clan=rng.randi_range(0,1)
 var kind=crises_seen%CRISIS_NAMES.size()
 var v=villages[clan]
 active_crisis={"kind":kind,"clan":clan,"until":day+18}
 crises_seen+=1
 crisis_history.push_front({"day":day,"kind":kind,"clan":clan})
 if crisis_history.size()>120:crisis_history.pop_back()
 if kind==0:v.food*=.55 if v.bonuses[0]<3 else .8
 elif kind==1:
  for a in people:
   if a.clan==clan and rng.randf()<.15:a.sick=6
 elif kind==2:peace=maxf(0,peace-32)
 elif kind==3:
  v.wood*=.65
  v.houses=maxi(3,int(v.houses)-2)
  changes.append({"kind":"house","clan":clan})
 elif kind==4:
  v.knowledge+=50
  for a in people:
   if a.clan==clan:a.mood=minf(100,a.mood+12)
 elif kind==5 and peace>40 and count(1-clan)>4:
  for a in people:
   if a.clan==1-clan and a.age>=18 and a.partner<0:
    a.clan=clan
    a.friend=-1
    remember(a,"Ho raggiunto "+CLANs_name(clan)+".")
    changes.append({"kind":"migration","id":a.id})
    break
 log_event(CLANs_name(clan)+" · "+CRISIS_NAMES[kind]+".")

func close_family(a:Dictionary,b:Dictionary)->bool:
 if a.parents.has(b.id) or b.parents.has(a.id):return true
 for parent in a.parents:
  if b.parents.has(parent):return true
 return false

func dispatch_shipment(clan:int,amount:float):
 if clan<0 or clan>1 or shipments.size()>=8:return
 amount=clampf(amount,0,minf(18,float(villages[clan].food)))
 if amount<1:return
 villages[clan].food-=amount
 var row={"id":next_shipment,"clan":clan,"depart":day,"due":day+5,"amount":amount}
 next_shipment+=1
 shipments.append(row)
 changes.append({"kind":"trade","clan":clan,"id":row.id})
 log_event("Carovana in partenza da "+CLANs_name(clan)+".")

func settle_shipments():
 for row in shipments.duplicate():
  if day<int(row.due):continue
  var clan=int(row.clan)
  if count(1-clan)>0 and peace>=25:
   villages[1-clan].food=minf(850,villages[1-clan].food+float(row.amount))
   villages[1-clan].knowledge+=2
   trades+=1
   log_event("Carovana arrivata a "+CLANs_name(1-clan)+".")
  else:
   lost_shipments+=1
   log_event("Una carovana non ha raggiunto la destinazione.")
  shipments.erase(row)
  changes.append({"kind":"trade_arrived","id":row.id})

func milestone(a:Dictionary,kind:String,message:String):
 if not a.has("life_story"):a.life_story=[]
 a.life_story.push_front({"day":day,"kind":kind,"text":message})
 if a.life_story.size()>40:a.life_story.pop_back()

func record_dialogue(a:Dictionary,speaker:String,message:String):
 if not a.has("dialogue"):a.dialogue=[]
 a.dialogue.append({"day":day,"speaker":speaker,"text":message.left(650)})
 if a.dialogue.size()>30:a.dialogue.pop_front()

func adjust_trust(a:Dictionary,delta:float):
 a.trust=clampf(float(a.get("trust",50))+delta,0,100)

func personality(a:Dictionary)->String:
 var traits=[]
 traits.append("Curioso" if a.genes[0]>.60 else "Pragmatico")
 traits.append("Empatico" if a.genes[1]>.55 else "Riservato")
 traits.append("Energico" if a.genes[3]>.58 else "Riflessivo")
 return ", ".join(traits)

func rename_person(a:Dictionary,value:String)->bool:
 var clean=value.strip_edges().replace("\n"," ").replace("\r"," ").left(24)
 if clean.is_empty() or not people.has(a):return false
 a.name=clean
 return true

func choose_social_action(a:Dictionary,v:Dictionary):
 a.social_target=-1
 a.social_need=minf(100,float(a.social_need)+2.5+float(a.genes[1])*2.0)
 if a.health<55 or a.hunger>60 or int(a.intention_until)>day:return
 if float(a.genes[1])>.48 and (day+int(a.id))%3==0:
  var recipient={}
  var highest=0.0
  for other in people:
   if other.id==a.id or other.clan!=a.clan or other.health<=0:continue
   if other.health>=80 and int(other.sick)<=0 and other.hunger<65:continue
   if int(other.get("last_aid_day",-1))==day:continue
   var need=maxf(0,80-float(other.health))+float(other.sick)*6+maxf(0,float(other.hunger)-60)
   if need>highest:recipient=other;highest=need
  if not recipient.is_empty():
   a.activity="Aiuta un vicino"
   a.social_target=recipient.id
   recipient.last_aid_day=day
   recipient.health=minf(100,recipient.health+3.0)
   recipient.mood=minf(100,recipient.mood+4)
   if recipient.sick>0:recipient.sick=maxi(0,int(recipient.sick)-1)
   if recipient.hunger>=65 and v.food>=2:
    v.food-=2
    recipient.hunger=maxf(0,recipient.hunger-10)
   a.social_need=maxf(0,a.social_need-18)
   a.skill=minf(100,a.skill+.25)
   social_actions+=1
   aid_actions+=1
   milestone(a,"Solidarietà","Ho aiutato "+recipient.name+".")
   milestone(recipient,"Solidarietà",a.name+" mi ha aiutato.")
   log_event(a.name+" aiuta "+recipient.name+".")
   return
 if (day+int(a.id))%5!=0:return
 if a.social_need>=60:
  var friend_data=find(int(a.friend))
  if friend_data.is_empty() or friend_data.clan!=a.clan:
   for other in people:
    if other.id!=a.id and other.clan==a.clan:
     friend_data=other
     break
  if not friend_data.is_empty():
   a.activity="Incontra un amico"
   a.social_target=friend_data.id
   a.social_need=maxf(0,a.social_need-45)
   a.mood=minf(100,a.mood+1)
   social_actions+=1
   meet_actions+=1
   return
 if int(v.project)>=0 and a.role=="Artigiano":
  a.activity="Lavora al progetto"
  v.progress=minf(99.9,float(v.progress)+.14)
  a.skill=minf(100,a.skill+.6)
  social_actions+=1
 elif a.activity=="Studia":
  a.skill=minf(100,a.skill+.45)

func init_tasks(a:Dictionary):
 a["fatigue"]=clampf(float(a.get("fatigue",25+int(a.id)%32)),0,100)
 a["boredom"]=clampf(float(a.get("boredom",20+int(a.id)%25)),0,100)
 a["task"]=str(a.get("task",""))
 if not TASK_LABELS.has(a.task):a.task=""
 a["task_target"]=int(a.get("task_target",-1))
 a["task_left"]=clampf(float(a.get("task_left",0)),0,8)
 a["task_reason"]=str(a.get("task_reason",""))
 a["tasks_done"]=int(a.get("tasks_done",0))
 a["last_task"]=str(a.get("last_task",""))
 a["bonds"]=a.get("bonds",{})
 if not a.bonds is Dictionary:a.bonds={}
 a["last_child_day"]=int(a.get("last_child_day",-40))
 a["task_stage"]="In viaggio" if a.task!="" else "Decide"
 a["home_key"]=str(a.get("home_key",""))
 a["station_id"]=str(a.get("station_id",""))
 a["delivery"]=bool(a.get("delivery",false))
 a["cargo"]=str(a.get("cargo",""))
 a["held_goods"]=str(a.get("held_goods",""))
 if a.held_goods not in ["","Cibo","Legna"]:a.held_goods=""
 a["stress"]=clampf(float(a.get("stress",0)),0,100)
 a["grief_until"]=int(a.get("grief_until",0))
 a["emotion"]=str(a.get("emotion","Sereno"))
 a["special_memory"]=str(a.get("special_memory",""))
 a["routine"]=str(a.get("routine",["Mattiniero","Equilibrato","Notturno"][int(a.id)%3]))
 a["special_until"]=int(a.get("special_until",0))
 a["coins"]=maxf(0,float(a.get("coins",3)))
 a["tool"]=clampf(float(a.get("tool",0)),0,100)
 a["work_history"]=a.get("work_history",{})
 if not a.work_history is Dictionary:a.work_history={}
 a["social_style"]=str(a.get("social_style","Conciliante" if a.genes[1]>.5 else "Competitivo"))
 a["action_values"]=a.get("action_values",{})
 if not a.action_values is Dictionary:a.action_values={}
 a["plan_goal"]=str(a.get("plan_goal",""))
 a["last_speech"]=str(a.get("last_speech",""))

func tick_needs(a:Dictionary,dt:float):
 a.hunger=minf(100,float(a.hunger)+dt*1.65)
 a.fatigue=minf(100,float(a.fatigue)+dt*1.15)
 a.boredom=minf(100,float(a.boredom)+dt*.9)
 a.social_need=minf(100,float(a.social_need)+dt*(.8+float(a.genes[1])*.55))
 var pressure=maxf(float(a.hunger),maxf(float(a.fatigue),100-float(a.health)))
 a.stress=clampf(float(a.stress)+dt*(.9 if pressure>80 else -.45),0,100)
 a.emotion="In lutto" if int(a.grief_until)>day else "Spaventato" if a.stress>65 else "Affamato" if a.hunger>75 else "Stanco" if a.fatigue>75 else "Felice" if a.mood>78 else "Triste" if a.mood<38 else "Sereno"

func choose_task(a:Dictionary,available:Dictionary={})->Dictionary:
 var v=villages[a.clan]
 var scores={}
 var targets={}
 var reasons={}
 var adult=float(a.age)>=14
 if v.food>=1:
  scores.eat=pow(float(a.hunger)/100,2)*140
  reasons.eat="Fame: "+str(int(a.hunger))+"%"
 scores.sleep=pow(float(a.fatigue)/100,2)*125+maxf(0,65-float(a.health))
 if a.fatigue>40:
  var night=(day%16>=9)
  if night and a.routine!="Notturno":scores.sleep+=15
  elif not night and a.routine=="Notturno":scores.sleep+=10
 reasons.sleep="Stanchezza: "+str(int(a.fatigue))+"%"
 if a.health<85 or a.sick>0:
  scores.heal=(100-float(a.health))*.8+float(a.sick)*9
  reasons.heal="Ha bisogno di cure"
 scores.play=8+pow(float(a.boredom)/100,2)*80+float(a.stress)*.25
 reasons.play="Ha bisogno di svago"
 scores.explore=10+float(a.genes[0])*15
 reasons.explore="Curiosità"
 if adult:
  scores.farm=18+maxf(0,90-float(v.food))*0.55+(18 if a.role=="Coltivatore" else 0)
  reasons.farm="Rifornire le scorte"
  if v.wood>=22 and day>=int(v.get("rebuild_after",0)) and v.houses<mini(housing_limit,3+int(count(a.clan)/4)+v.era):
   scores.house=45+(25 if str(a.get("home_key",""))=="" else 0)+(12 if a.role=="Artigiano" else 0)
   reasons.house="La comunità necessita di nuove case"
  scores.gather=12+maxf(0,50-float(v.wood))*.5+(10 if a.role=="Artigiano" else 0)
  if spatial_autonomy and v.tech>=2 and v.wood>=4 and a.tool<15:
   scores.craft=25+(15 if a.role=="Artigiano" else 0)
   reasons.craft="Produrre un utensile personale"
  if spatial_autonomy and peace<25 and a.health>55 and a.hunger<75 and a.fatigue<75:
   scores.guard=32+(22 if a.role=="Guardiano" else 0)
   reasons.guard="Difendere il confine"
  if spatial_autonomy:
   for child in people:
    if child.age<14 and child.parents.has(a.id) and child.social_need>40:
     scores.teach=35+float(child.social_need)*.25
     targets.teach=child.id
     reasons.teach="Educare "+child.name
     break
  reasons.gather="Servono materiali"
  scores.research=13+float(a.genes[0])*25+(18 if a.role=="Ricercatore" else 0)
  reasons.research="Desiderio di conoscenza"
  if int(v.project)>=0:
   scores.build=25+(18 if a.role=="Artigiano" else 0)
   reasons.build="Completare un'opera"
 var friend_data=find(int(a.partner)) if a.partner>=0 else find(int(a.friend))
 if friend_data.is_empty() or friend_data.clan!=a.clan:
  var candidates=people.filter(func(other):return other.id!=a.id and other.clan==a.clan and other.health>40)
  if not candidates.is_empty():friend_data=candidates[(int(a.id)+int(a.tasks_done))%candidates.size()]
 if not friend_data.is_empty():
  scores.social=pow(float(a.social_need)/100,2)*95+float(a.genes[1])*10
  targets.social=int(friend_data.id)
  reasons.social="Desiderio di compagnia"
  if int(a.grief_until)>day:
   scores.social+=22
   reasons.social="Cerca conforto dopo un lutto"
 if adult and a.genes[1]>.48 and a.health>55:
  var greatest=0.0
  for other in people:
   if other.id==a.id or other.clan!=a.clan or other.health<=0 or int(other.get("last_aid_day",-1))==day:continue
   if other.health>=80 and other.sick<=0 and other.hunger<65:continue
   var need=maxf(0,80-float(other.health))+float(other.sick)*7+maxf(0,float(other.hunger)-60)
   var related=other.parents.has(a.id) or a.parents.has(other.id) or int(a.partner)==int(other.id)
   if related:need*=1.6
   if need>greatest:
    greatest=need
    targets.aid=int(other.id)
  if greatest>0:
   scores.aid=25+greatest*.9
   reasons.aid="Un vicino ha bisogno di aiuto"
 if int(a.intention_until)>day:
  var wanted={"RICERCA":"research","CIBO":"farm","CURA":"heal","PACE":"social","ESPLORA":"explore"}.get(a.intention,"")
  if scores.has(wanted):scores[wanted]+=28
 if spatial_autonomy:
  var council=str(v.get("council_focus",""))
  var focus_task={"CIBO":"farm","CASA":"house","CURA":"heal","SOCIALE":"social","RICERCA":"research"}.get(council,"")
  if scores.has(focus_task):scores[focus_task]+=12
  var policy_task={"Sostentamento":"farm","Sapere":"research","Solidarietà":"aid","Dimore":"house","Comunità":"social"}.get(str(v.culture.policy),"")
  if scores.has(policy_task):scores[policy_task]+=10
  var identity=str(v.get("identity",""))
  var preference={"Pacifista":"aid","Militarista":"guard","Scientifica":"research","Mercantile":"craft","Nomade":"explore","Esploratrice":"explore","Religiosa":"social"}.get(identity,"")
  if scores.has(preference):scores[preference]+=18
  if identity=="Militarista" and scores.has("guard"):scores.guard+=8
  if adult and v.houses*4<count(a.clan) and day>=int(v.get("rebuild_after",0)) and a.hunger<70 and a.fatigue<70:
   a.plan_goal="house"
   if v.wood<22 and scores.has("gather"):
    scores.gather+=42
    reasons.gather="Piano: procurare legna per una dimora"
   elif scores.has("house"):
    scores.house+=30
    reasons.house="Piano: completare la dimora"
  elif a.plan_goal=="house":a.plan_goal=""
 var best=""
 var best_score=-1.0
 for key in scores:
  if not available.is_empty() and not available.has(key):continue
  var value=float(scores[key])+float(posmod(int(a.id)*17+int(a.tasks_done)*13+str(key).hash(),9))*.6
  if spatial_autonomy:value+=clampf(float(a.action_values.get(key,0)), -12,12)
  if key=="eat" and a.hunger>=85:value+=100
  if key=="sleep" and a.fatigue>=92:value+=65
  if available.has(key):value/=1.0+float(available[key])*.018
  if key==a.last_task and value<95:value*=.55
  if value>best_score:
   best=key
   best_score=value
 if best=="":best="explore"
 var durations={"craft":4.0,"teach":3.0,"guard":3.0,"house":6.0,"eat":2.5,"sleep":5.0,"heal":3.5,"farm":4.5,"gather":4.0,"research":5.0,"build":5.0,"social":3.5,"aid":3.0,"play":3.0,"explore":2.0}
 return {"kind":best,"target":int(targets.get(best,-1)),"duration":float(durations.get(best,2.0)),"reason":str(reasons.get(best,""))}

func begin_task(a:Dictionary,plan:Dictionary):
 a.task=plan.kind
 a.task_target=plan.target
 a.task_left=plan.duration
 a.task_reason=plan.reason
 a.task_stage="In viaggio"
 a.activity=TASK_LABELS.get(a.task,"Decide")
 a.social_target=a.task_target

func complete_task(a:Dictionary)->bool:
 if not TASK_LABELS.has(a.task):return false
 var v=villages[a.clan]
 var ok=true
 var action=str(a.task)
 match a.task:
  "craft":
   if v.wood<4:ok=false
   else:
    v.wood-=4
    a.tool=100.0
    a.skill=minf(100,a.skill+1)
  "teach":
   var child=find(int(a.task_target))
   if child.is_empty() or child.age>=14:ok=false
   else:
    child.social_need=maxf(0,child.social_need-40)
    child.skill=minf(100,child.skill+2)
    child.mood=minf(100,child.mood+8)
    a.mood=minf(100,a.mood+4)
    milestone(child,"Educazione","Ho imparato da "+a.name+".")
  "guard":
   if peace>=25:ok=false
   else:a.skill=minf(100,a.skill+.5)
  "eat":
   if v.food<1:ok=false
   else:
    v.food-=1
    a.coins=maxf(0,a.coins-1)
    a.hunger=maxf(0,a.hunger-65)
  "sleep":
   a.fatigue=maxf(0,a.fatigue-82)
   a.stress=maxf(0,a.stress-15)
   a.health=minf(100,a.health+3)
  "heal":
   a.health=minf(100,a.health+10)
   a.sick=maxi(0,int(a.sick)-2)
  "house":
   if v.wood<22:ok=false
   else:
    v.wood-=22
    v.houses+=1
    changes.append({"kind":"house","clan":a.clan})
    log_event(CLANs_name(a.clan)+" costruisce una nuova casa.")
  "farm":
   var yield_amount=5.0*(1.2 if a.tool>0 else 1.0)
   if weather_name=="Siccità":yield_amount*=.65
   if season=="Inverno":yield_amount*=.85
   v.food=minf(850,v.food+yield_amount)
   a.tool=maxf(0,a.tool-8)
   a.skill=minf(100,a.skill+.5)
  "gather":
   v.wood=minf(400,v.wood+(7 if a.tool>0 else 5))
   a.tool=maxf(0,a.tool-10)
   a.skill=minf(100,a.skill+.3)
  "research":
   v.knowledge+=1.3+float(a.genes[0])
   a.skill=minf(100,a.skill+.7)
  "build":
   if int(v.project)<0:ok=false
   else:
    v.progress=minf(100,float(v.progress)+5.0)
    a.skill=minf(100,a.skill+.6)
  "social":
   var friend_data=find(int(a.task_target))
   if friend_data.is_empty():ok=false
   else:
    a.social_need=maxf(0,a.social_need-65)
    friend_data.social_need=maxf(0,friend_data.social_need-25)
    a.mood=minf(100,a.mood+5)
    if spatial_autonomy:
     build_relationship(a,friend_data)
     a.stress=maxf(0,a.stress-12)
     friend_data.mood=minf(100,friend_data.mood+3)
     procedural_exchange(a,friend_data)
    elif a.friend<0 and friend_data.friend<0:
     a.friend=friend_data.id
     friend_data.friend=a.id
     milestone(a,"Amicizia","Ho conosciuto "+friend_data.name+".")
    social_actions+=1
    meet_actions+=1
  "aid":
   var patient=find(int(a.task_target))
   if patient.is_empty():ok=false
   else:
    patient.health=minf(100,patient.health+4)
    patient.sick=maxi(0,int(patient.sick)-1)
    patient.last_aid_day=day
    if patient.hunger>60 and v.food>=1:
     v.food-=1
     patient.hunger=maxf(0,patient.hunger-12)
    a.social_need=maxf(0,a.social_need-25)
    social_actions+=1
    aid_actions+=1
    milestone(a,"Solidarietà","Ho aiutato "+patient.name+".")
    milestone(patient,"Solidarietà",a.name+" mi ha aiutato.")
    log_event(a.name+" aiuta "+patient.name+".")
  "play","explore":
   a.boredom=maxf(0,a.boredom-(65 if a.task=="play" else 30))
   a.stress=maxf(0,a.stress-10)
   a.mood=minf(100,a.mood+3)
 if spatial_autonomy:learn_action(a,action,3.0 if ok else -4.0)
 if ok:
  if action=="house":a.plan_goal=""
  a.tasks_done+=1
  a.last_task=a.task
  a.work_history[action]=int(a.work_history.get(action,0))+1
  if action in ["farm","gather","build","house","research","craft","guard"]:
   if not market_mode:a.coins=minf(999,a.coins+1.5)
   if spatial_autonomy and not market_mode:
    var contribution=minf(.25,float(a.coins))
    a.coins-=contribution
    v.culture.treasury=minf(2000,float(v.culture.treasury)+contribution)
  if spatial_autonomy:
   v.culture.actions[action]=int(v.culture.actions.get(action,0))+1
   if action=="teach":v.culture.heritage=mini(100,int(v.culture.heritage)+1)
 a.task=""
 a.task_stage="Decide"
 a.task_target=-1
 a.social_target=-1
 a.task_left=0
 a.station_id=""
 a.delivery=false
 a.cargo=""
 return ok

func build_relationship(a:Dictionary,b:Dictionary):
 var ak=str(b.id)
 var bk=str(a.id)
 if a.bonds.size()>=24 and not a.bonds.has(ak):a.bonds.erase(a.bonds.keys()[0])
 if b.bonds.size()>=24 and not b.bonds.has(bk):b.bonds.erase(b.bonds.keys()[0])
 var gain=12.0+float(a.genes[1])*9.0
 if a.stress>75 and b.stress>60 and a.social_style=="Competitivo":
  gain=-10.0
  a.special_memory="Ho discusso con "+b.name
  a.special_until=day+4
  b.special_memory="Ho discusso con "+a.name
  b.special_until=day+4
  a.mood=maxf(0,a.mood-5)
  b.mood=maxf(0,b.mood-5)
  log_event(a.name+" discute con "+b.name+".")
 var level=clampf(float(a.bonds.get(ak,0))+gain,-100,100)
 a.bonds[ak]=level
 b.bonds[bk]=clampf(float(b.bonds.get(bk,0))+gain,-100,100)
 if level>=30 and a.friend<0 and b.friend<0:
  a.friend=b.id
  b.friend=a.id
  milestone(a,"Amicizia","Ho conosciuto "+b.name+".")
  milestone(b,"Amicizia","Ho conosciuto "+a.name+".")
 if a.age<14 or b.age<14 or a.health<60 or b.health<60 or a.clan!=b.clan or close_family(a,b):return
 if level>=65 and a.partner<0 and b.partner<0:
  a.partner=b.id
  b.partner=a.id
  milestone(a,"Unione","Ho scelto "+b.name+".")
  milestone(b,"Unione","Ho scelto "+a.name+".")
  a.special_memory="Insieme a "+b.name
  b.special_memory="Insieme a "+a.name
  a.special_until=day+5
  b.special_until=day+5
  a.mood=minf(100,a.mood+15)
  b.mood=minf(100,b.mood+15)
  log_event(a.name+" e "+b.name+" si uniscono.")
 if a.partner==b.id and b.partner==a.id and level>=75 and day-int(a.last_child_day)>=18 and day-int(b.last_child_day)>=18 and villages[a.clan].food>=count(a.clan)*2 and people.size()<population_limit:
  a.last_child_day=day
  b.last_child_day=day
  var child=birth(a.clan,[a,b])
  if not child.is_empty():
   milestone(a,"Famiglia","È nato "+child.name+".")
   milestone(b,"Famiglia","È nato "+child.name+".")
   a.special_memory="È nato "+child.name
   b.special_memory=a.special_memory
   a.special_until=day+7
   b.special_until=day+7
   log_event("Nasce "+child.name+".")

func learn_action(a:Dictionary,kind:String,reward:float):
 if not TASK_LABELS.has(kind):return
 a.action_values[kind]=clampf(float(a.action_values.get(kind,0))*.85+reward*.3,-12,12)

func procedural_exchange(a:Dictionary,b:Dictionary):
 var v=villages[a.clan]
 var first=""
 var second=""
 if a.grief_until>day:
  first="Mi manca chi non è più qui."
  second="Non devi affrontare tutto da solo."
 elif a.hunger>65 or v.food<float(count(a.clan)):
  first="Temo che le scorte non bastino."
  second="Cerchiamo altro cibo per il villaggio."
 elif a.stress>70 and b.stress>65:
  first="Sono stanco di queste difficoltà."
  second="Proviamo a trovare una soluzione."
 elif a.partner==b.id:
  first="Come sta la nostra famiglia?"
  second="La nostra casa è importante per me."
 elif bool(a.get("dissident",false)) or bool(b.get("dissident",false)):
  first="Il Creatore merita davvero la nostra fede?"
  second="Ho paura, ma voglio scegliere." if float(b.faith)<50 else "Ricordo anche i suoi doni."
 elif a.genes[0]>.65:
  first=["Cosa c'è oltre le colline?","Vorrei capire come funziona il cielo.","Possiamo inventare qualcosa di nuovo."][posmod(int(a.tasks_done)+day,3)]
  second="Proviamoci insieme." if b.genes[0]>.5 else "Prima pensiamo al villaggio."
 elif a.health<65 or b.health<65:
  first="Ti senti meglio oggi?"
  second="Un po' di riposo mi farebbe bene."
 else:
  first=["È bello ritrovarsi.","Hai visto il nuovo giorno?","Che cosa hai fatto oggi?"][posmod(int(a.id)+int(a.tasks_done)+day,3)]
  second=["Mi piace vivere qui.","Vorrei riposare un po'.","Ho ancora tante cose da fare."][posmod(int(b.id)+day,3)]
 for citizen in [a,b]:
  record_dialogue(citizen,a.name,first)
  record_dialogue(citizen,b.name,second)
 a.last_speech=first
 b.last_speech=second
 a.special_memory=first
 b.special_memory=second
 a.special_until=day+2
 b.special_until=day+2

func storyteller():
 for clan in range(2):
  var v=villages[clan]
  var inhabitants=people.filter(func(a):return a.clan==clan)
  if inhabitants.is_empty():continue
  var stress=0.0
  var sick=0
  for a in inhabitants:
   stress+=float(a.stress)
   if a.sick>0:sick+=1
  var focus="RICERCA"
  var message="Il consiglio incoraggia nuove scoperte."
  if v.food<float(inhabitants.size())*1.5:
   focus="CIBO"
   message="Il consiglio chiede di rifornire il magazzino."
  elif sick>=maxi(2,int(inhabitants.size()/4)):
   focus="CURA"
   message="Il consiglio organizza le cure."
  elif v.houses*4<inhabitants.size():
   focus="CASA"
   message="Il consiglio vuole nuove dimore."
  elif stress/float(inhabitants.size())>40:
   focus="SOCIALE"
   message="Il consiglio invita gli abitanti a sostenersi."
  if str(v.get("council_focus",""))!=focus:
   v["council_focus"]=focus
   log_event(CLANs_name(clan)+": "+message)


# Culture lives in village records; version-2 saves migrate in place.
const CULTURE_POLICIES=["Sostentamento","Sapere","Solidarietà","Dimore","Comunità"]
func init_culture(v:Dictionary):
 var raw=v.get("culture",{})
 if not raw is Dictionary:raw={}
 var policy=str(raw.get("policy","Comunità"))
 if not CULTURE_POLICIES.has(policy):policy="Comunità"
 var archive=raw.get("archive",[])
 if not archive is Array:archive=[]
 var actions=raw.get("actions",{})
 if not actions is Dictionary:actions={}
 v["culture"]={"policy":policy,"leader":int(raw.get("leader",-1)),"treasury":clampf(float(raw.get("treasury",0)),0,2000),"heritage":clampi(int(raw.get("heritage",0)),0,100),"archive":archive.slice(0,24),"actions":actions,"festivals":maxi(0,int(raw.get("festivals",0))),"relief":maxi(0,int(raw.get("relief",0))),"next_vote":maxi(1,int(raw.get("next_vote",7))),"next_festival":maxi(1,int(raw.get("next_festival",30))),"votes":raw.get("votes",{})}
 if not v.culture.votes is Dictionary:v.culture.votes={}

func cultural_event(clan:int,message:String,kind:String):
 var culture=villages[clan].culture
 culture.archive.push_front({"day":day,"text":message,"kind":kind})
 if culture.archive.size()>24:culture.archive.pop_back()
 log_event(CLANs_name(clan)+": "+message)
 changes.append({"kind":"culture","clan":clan,"text":message,"event_type":kind})

func advance_culture():
 for clan in range(2):
  var v=villages[clan]
  var c=v.culture
  var inhabitants=people.filter(func(a):return int(a.clan)==clan)
  if inhabitants.is_empty():continue
  var leader=find(int(c.leader))
  if day>=int(c.next_vote) or (int(c.leader)>=0 and (leader.is_empty() or int(leader.clan)!=clan)):
   c.next_vote=day+14
   var votes={}
   for policy in CULTURE_POLICIES:votes[policy]=0
   var leader_id=-1
   var best_merit=-1.0
   for a in inhabitants:
    if float(a.age)<14:continue
    var vote="Comunità"
    if float(a.hunger)>50 or float(v.food)<inhabitants.size()*1.5:vote="Sostentamento"
    elif float(a.health)<65 or int(a.sick)>0:vote="Solidarietà"
    elif v.houses*4<inhabitants.size():vote="Dimore"
    elif float(a.social_need)>55 or float(a.stress)>55:vote="Comunità"
    elif float(a.genes[0])>.58:vote="Sapere"
    elif float(a.genes[1])>.65:vote="Solidarietà"
    votes[vote]+=1
    var merit=float(a.skill)+float(a.genes[1])*20+minf(30,float(a.tasks_done)*.1)
    if merit>best_merit:best_merit=merit;leader_id=int(a.id)
   var winner="Comunità"
   for policy in CULTURE_POLICIES:
    if int(votes[policy])>int(votes[winner]):winner=policy
   c.votes=votes
   c.policy=winner
   c.leader=leader_id
   var chosen=find(leader_id)
   if not chosen.is_empty():cultural_event(clan,"Il consiglio sceglie "+str(chosen.name)+" e la priorità "+winner+".","vote")
  if c.policy=="Solidarietà" or c.policy=="Sostentamento":
   for a in inhabitants:
    if float(c.treasury)<1.0 or float(v.food)<1.0:break
    if float(a.hunger)>65 and float(a.coins)<2:
     c.treasury-=1.0
     v.food-=1.0
     a.hunger=maxf(0,float(a.hunger)-18.0)
     c.relief+=1
  if day>=int(c.next_festival):
   c.next_festival=day+30
   var cost=maxf(3.0,float(inhabitants.size())*.3)
   if float(v.food)>float(inhabitants.size())*2.0+cost and float(c.treasury)>=cost:
    v.food-=cost
    c.treasury-=cost
    c.festivals+=1
    c.heritage=mini(100,int(c.heritage)+3)
    for a in inhabitants:
     a.mood=minf(100,float(a.mood)+8)
     a.social_need=maxf(0,float(a.social_need)-10)
    cultural_event(clan,"Festa della memoria: il popolo celebra la propria storia.","festival")
   else:cultural_event(clan,"La festa viene rimandata per conservare le risorse.","postponed")

func culture_report()->String:
 var lines=[]
 for clan in range(2):
  var v=villages[clan]
  var c=v.culture
  var leader=find(int(c.leader))
  lines.append("%s · %s\nPriorità: %s\nDelegato: %s\nCassa comune: %.1f · Eredità: %d/100\nFeste: %d · Aiuti alimentari: %d\nProssimo consiglio: giorno %d"%[CLANS[clan],v.government,c.policy,leader.get("name","Nessuno"),float(c.treasury),int(c.heritage),int(c.festivals),int(c.relief),int(c.next_vote)])
  var vote_lines=[]
  for policy in CULTURE_POLICIES:vote_lines.append("%s %d"%[policy,int(c.votes.get(policy,0))])
  lines.append("Voti: "+", ".join(vote_lines))
  for event in c.archive.slice(0,5):lines.append("G%d · %s"%[int(event.day),str(event.text)])
  lines.append("")
 return "\n".join(lines)
