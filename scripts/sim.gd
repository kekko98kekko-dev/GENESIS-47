extends RefCounted
const CLANS=["Auralis","Nerith"]
const ERAS=["Origini","Tribù","Agricoltura","Regni","Industria","Stelle","Contatto"]
const NAMES=["Arel","Nima","Sorin","Elya","Taro","Lumi","Kiran","Iria","Nox","Sela","Oren","Veya","Miro","Fenn","Lior","Asha"]
const TECH=["Fuoco","Utensili","Agricoltura","Scrittura","Medicina","Architettura","Commercio","Metallurgia","Elettricità","Industria","Calcolo","Astronomia","Reti neurali","Segnale oltre il cielo"]
const LIMIT=160
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
var active_crisis={}
var crisis_history:Array=[]
const CRISIS_NAMES=["Siccità prolungata","Epidemia","Crisi diplomatica","Tempesta","Rinascimento culturale","Migrazione"]
const PROJECT_NAMES=["Granai comunitari","Accademia delle scienze","Giardino della salute","Ambasciata","Osservatorio del cielo","Monumento della memoria"]
func start(s:int,m:int):
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
 active_crisis.clear()
 crisis_history.clear()
 weather_name="Sereno"
 season="Primavera"
 for i in range(2):
  villages.append({"food":72.0 if m!=3 else 26.0,"wood":35.0,"knowledge":0.0,"faith":55.0,"era":0,"houses":3,"government":"Consiglio","belief":"Il cielo vivente","tech":0,"project":-1,"progress":0.0,"completed":0,"bonuses":[0,0,0,0,0,0]})
  for j in range(14):
   birth(i,[])
 log_event("Il mondo si risveglia. Due popoli, un cielo.")
func birth(c:int,parents:Array)->Dictionary:
 if people.size()>=LIMIT: return {}
 var genes=[rng.randf_range(.25,.85),rng.randf_range(.25,.85),rng.randf_range(.25,.85),rng.randf_range(.25,.85)]
 var ids=[]
 var gen=1
 if parents.size()==2:
  gen=maxi(int(parents[0].gen),int(parents[1].gen))+1
  for p in parents: ids.append(p.id)
  for i in range(4): genes[i]=clampf((float(parents[0].genes[i])+float(parents[1].genes[i]))*.5+rng.randf_range(-.12,.12),.04,.98)
 var a={"id":next_id,"name":NAMES[rng.randi_range(0,NAMES.size()-1)]+" "+str(next_id),"clan":c,"age":0.0 if ids.size()==2 else rng.randf_range(17,32),"gen":gen,"health":100.0,"hunger":rng.randf_range(0,25),"faith":55.0,"mood":75.0,"genes":genes,"parents":ids,"partner":-1,"friend":-1,"role":"Esploratore","goal":"Conoscere il mondo","memories":["Ho visto la luce del mondo."],"favorite":false,"sick":0,"prophet":false,"activity":"Esplora","intention":"","intention_until":0,"trust":50.0,"life_story":[],"dialogue":[]}
 next_id+=1
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
   remember(b,"Ho perso "+a.name+".")
   milestone(b,"Lutto","Ho perso "+a.name+".")
   if b.partner==a.id:b.partner=-1
   if b.friend==a.id:b.friend=-1
 total_deaths+=1
 dead.append({"id":a.id,"name":a.name,"gen":a.gen,"day":day,"reason":why,"clan":a.clan,"parents":a.parents.duplicate()})
 if dead.size()>3000:dead.pop_front()
 changes.append({"kind":"death","id":a.id})
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
  v.food=clampf(v.food+n*(productivity*weather-.96),0,850)
  v.wood=minf(400,v.wood+n*.16)
  var thinkers=0.0
  for a in people:
   if a.clan==i:thinkers+=float(a.genes[0])
  v.knowledge+=thinkers*(.23+minf(.10,float(v.bonuses[1])*.01))
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
  if v.wood>=22 and v.houses<mini(25,3+int(n/5)+v.era):
   v.wood-=22
   v.houses+=1
   changes.append({"kind":"house","clan":i})
  if day%5==0 and n>1 and v.food>n*.65 and people.size()<LIMIT:
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
  if day%17==0 and n>2:
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
  if day%12==0 and peace>45:
   var donor=0 if villages[0].food>villages[1].food else 1
   var amount=minf(18,villages[donor].food*.12)
   if amount>=1.0:dispatch_shipment(donor,amount)
  if peace<25 and day%5==0 and not people.is_empty():
   var victim=people[rng.randi_range(0,people.size()-1)]
   victim.health-=25
   remember(victim,"Sono stato ferito in guerra.")
 for a in people.duplicate():
  var v=villages[a.clan]
  var old_age=int(a.age)
  a.age+=.22
  if int(a.age)>old_age and int(a.age) in [14,30,50,70]:milestone(a,"Età","Ho raggiunto "+str(int(a.age))+" anni.")
  a.hunger=clampf(a.hunger+(8 if v.food<counts[a.clan]*.38 else -6),0,100)
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
  if a.health<=0 or a.age>83:die(a,"vecchiaia" if a.age>83 else "malattia" if int(a.sick)>0 else "carestia" if a.hunger>75 else "ferite")
 if day%25==0 and not people.is_empty():
  var a=people[rng.randi_range(0,people.size()-1)]
  var question="Creatore, perché esiste la sofferenza?" if a.mood<50 else ("Abbiamo osservato anomalie. Il nostro mondo è reale?" if villages[a.clan].era>=4 else ("I nostri raccolti basteranno per tutti?" if day%50==0 else "Creatore, ci ascolti?"))
  remember(a,question)
  signals.push_front({"id":a.id,"text":question,"day":day,"answered":false})
  if signals.size()>12:signals.pop_back()
  log_event(a.name+": «"+question+"»")
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
 return {"version":2,"seed":seed_value,"day":day,"mode":mode,"energy":energy,"peace":peace,"next_id":next_id,"ended":ended,"people":people,"dead":dead,"villages":villages,"events":events,"discoveries":discoveries,"signals":signals,"trades":trades,"shipments":shipments,"next_shipment":next_shipment,"lost_shipments":lost_shipments,"miracles":miracles,"rng":str(rng.state),"weather":weather_name,"season":season,"achievements":achievements,"history":history,"decisions":decisions,"diplomacy":diplomacy_state,"autonomous_decisions":autonomous_decisions,"extinction_noted":extinction_noted,"legacy_cycles":legacy_cycles,"total_deaths":total_deaths,"total_births":total_births,"projects_completed":projects_completed,"active_crisis":active_crisis,"crises_seen":crises_seen,"crisis_history":crisis_history}
func import_state(d:Dictionary)->bool:
 if d.get("version",0)!=2 or not d.get("people") is Array or not d.get("villages") is Array or d.villages.size()!=2:return false
 for key in ["seed","day","mode","energy","peace","next_id","ended","dead","events","discoveries","signals","trades","miracles","rng"]:
  if not d.has(key):return false
 if int(d.mode)<0 or int(d.mode)>3 or d.people.size()>LIMIT:return false
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
 v.progress=minf(100,float(v.progress)+2.0+minf(5.0,n*.065))
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
