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
var miracles=0
var changes:Array=[]
var weather_name="Sereno"
var season="Primavera"
var achievements:Array=[]
var history:Array=[]
var decisions:Array=[]
var diplomacy_state="Neutralità"
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
 weather_name="Sereno"
 season="Primavera"
 for i in range(2):
  villages.append({"food":72.0 if m!=3 else 26.0,"wood":35.0,"knowledge":0.0,"faith":55.0,"era":0,"houses":3,"government":"Consiglio","belief":"Il cielo vivente","tech":0})
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
 var a={"id":next_id,"name":NAMES[rng.randi_range(0,NAMES.size()-1)]+" "+str(next_id),"clan":c,"age":0.0 if ids.size()==2 else rng.randf_range(17,32),"gen":gen,"health":100.0,"hunger":rng.randf_range(0,25),"faith":55.0,"mood":75.0,"genes":genes,"parents":ids,"partner":-1,"friend":-1,"role":"Esploratore","goal":"Conoscere il mondo","memories":["Ho visto la luce del mondo."],"favorite":false,"sick":0,"prophet":false,"activity":"Esplora"}
 next_id+=1
 people.append(a)
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
   if b.partner==a.id:b.partner=-1
   if b.friend==a.id:b.friend=-1
 dead.append({"id":a.id,"name":a.name,"gen":a.gen,"day":day,"reason":why})
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
 var counts=[count(0),count(1)]
 for i in range(2):
  var v=villages[i]
  var n=counts[i]
  if n==0:continue
  var weather=.58 if mode==3 and day<60 else 1.0
  weather*=.68 if weather_name=="Siccità" else (1.12 if weather_name=="Pioggia" else .89 if season=="Inverno" else 1.0)
  var productivity=1.20+float(v.era)*.15
  v.food=clampf(v.food+n*(productivity*weather-.96),0,850)
  v.wood=minf(400,v.wood+n*.16)
  var thinkers=0.0
  for a in people:
   if a.clan==i:thinkers+=float(a.genes[0])
  v.knowledge+=thinkers*.23
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
     var candidates=adults.filter(func(other):return other.id!=a.id and other.partner<0 and not a.parents.has(other.id) and not other.parents.has(a.id) and (a.parents.is_empty() or not a.parents.has(other.parents[0] if not other.parents.is_empty() else -1)))
     if not candidates.is_empty():b=candidates[rng.randi_range(0,candidates.size()-1)]
    if b.is_empty():continue
    if a.id!=b.id:
     a.partner=b.id
     b.partner=a.id
     var child=birth(i,[a,b])
     if not child.is_empty():
      remember(a,"È nato "+child.name+".")
      remember(b,"È nato "+child.name+".")
  if day%17==0 and n>2:
   var clan_people=people.filter(func(a):return a.clan==i)
   var a=clan_people[rng.randi_range(0,clan_people.size()-1)]
   var b=clan_people[rng.randi_range(0,clan_people.size()-1)]
   if a.id!=b.id:
    a.friend=b.id
    b.friend=a.id
    remember(a,"Mi sono avvicinato a "+b.name+".")
    a.mood=minf(100,a.mood+8)
  if day%23==0 and v.food<n*.5:
   v.government="Consiglio di emergenza"
   log_event(CLANs_name(i)+" cambia governo per la crisi.")
 if counts[0]>0 and counts[1]>0:
  peace=clampf(peace+rng.randf_range(-2,2)+(.4 if villages[0].food>20 and villages[1].food>20 else -.6),0,100)
  var new_relation="Guerra" if peace<25 else ("Alleanza" if peace>=80 else "Tregua" if peace>=45 else "Tensione")
  if new_relation!=diplomacy_state:
   diplomacy_state=new_relation
   log_event("Relazioni fra i popoli: "+new_relation+".")
  if day%12==0 and peace>45:
   var donor=0 if villages[0].food>villages[1].food else 1
   var amount=minf(18,villages[donor].food*.12)
   villages[donor].food-=amount
   villages[1-donor].food+=amount
   villages[1-donor].knowledge+=2
   trades+=1
   changes.append({"kind":"trade","clan":donor})
   log_event("Una carovana commercia fra i due popoli.")
  if peace<25 and day%5==0 and not people.is_empty():
   var victim=people[rng.randi_range(0,people.size()-1)]
   victim.health-=25
   remember(victim,"Sono stato ferito in guerra.")
 for a in people.duplicate():
  var v=villages[a.clan]
  a.age+=.22
  a.hunger=clampf(a.hunger+(8 if v.food<counts[a.clan]*.38 else -6),0,100)
  a.health=clampf(a.health+(1.4 if a.hunger<40 else -2.7)-(1.5 if a.age>65 else 0),0,100)
  a.mood=clampf(a.mood+(1 if a.health>70 and a.hunger<35 else -2),0,100)
  if day%19==0 and rng.randf()<.045:a.sick=6
  if int(a.get("sick",0))>0:
   a.sick=int(a.sick)-1
   a.health=maxf(0,a.health-(2 if v.tech>=5 else 5))
   if a.sick==5:remember(a,"Mi sono ammalato.")
  a.role="Profeta" if a.get("prophet",false) else ("Ricercatore" if a.genes[0]>.65 and v.era>=2 else ("Coltivatore" if a.genes[1]>.53 else "Artigiano" if v.era>=2 else "Esploratore"))
  a.activity="Riposa" if a.health<50 or day%4==0 else ("Cerca cibo" if a.hunger>50 or a.role=="Coltivatore" else ("Studia" if a.role=="Ricercatore" else ("Incontra la famiglia" if a.partner>=0 and day%3==0 else "Esplora")))
  a.goal="Capire i confini del cielo" if v.era>=5 and a.genes[0]>.6 else "Proteggere la famiglia" if a.partner>=0 else "Scoprire un luogo nuovo"
  if a.health<=0 or a.age>83:die(a,"fine della vita")
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
 if ended!="":return
 if people.is_empty():ended="ESTINZIONE — Il cielo è rimasto solo."
 elif mode==1 and day>=90 and peace>=70 and villages[0].era>=3 and villages[1].era>=3:ended="L'ALLEANZA — Due popoli, un futuro condiviso."
 elif mode==2 and day>=100 and maxi(villages[0].era,villages[1].era)>=6:ended="OLTRE IL CIELO — Creatore, adesso sappiamo."
 elif mode==3 and day>=120 and people.size()>=24:ended="L'ULTIMA SCINTILLA — La vita continua."
func apply_reply(a:Dictionary,txt:String):
 remember(a,"Il Creatore: "+txt.left(300))
 var response=""
 if a.genes[0]>.67 and villages[a.clan].era>=3:response="Ti ascolto, ma le risposte vanno dimostrate. "+a.goal+"."
 elif a.mood<40:response="Abbiamo paura. Puoi aiutarci davvero?"
 elif a.faith>65:response="Le tue parole saranno ricordate dai nostri figli."
 else:response="Ricorderò le tue parole. "+a.goal+"."
 var message=txt.to_lower()
 if message.contains("pace") or message.contains("amore"):
  peace=minf(100,peace+3)
  a.mood=minf(100,a.mood+5)
 elif message.contains("guerra") or message.contains("punizione"):
  a.faith=clampf(a.faith+(5 if a.genes[0]<.5 else -5),0,100)
  a.mood=maxf(0,a.mood-7)
 elif message.contains("scienza") or message.contains("conoscenza"):
  villages[a.clan].knowledge+=2
 remember(a,response)
 for s in signals:
  if s.id==a.id:s.answered=true
 log_event(a.name+": «"+response+"»")
func export_state()->Dictionary:
 return {"version":2,"seed":seed_value,"day":day,"mode":mode,"energy":energy,"peace":peace,"next_id":next_id,"ended":ended,"people":people,"dead":dead,"villages":villages,"events":events,"discoveries":discoveries,"signals":signals,"trades":trades,"miracles":miracles,"rng":str(rng.state),"weather":weather_name,"season":season,"achievements":achievements,"history":history,"decisions":decisions,"diplomacy":diplomacy_state}
func import_state(d:Dictionary)->bool:
 if d.get("version",0)!=2 or not d.get("people") is Array or not d.get("villages") is Array or d.villages.size()!=2:return false
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
 miracles=int(d.miracles)
 weather_name=str(d.get("weather","Sereno"))
 season=str(d.get("season","Primavera"))
 achievements=d.get("achievements",[])
 history=d.get("history",[])
 decisions=d.get("decisions",[])
 diplomacy_state=str(d.get("diplomacy","Neutralità"))
 rng.seed=seed_value
 rng.state=int(str(d.rng))
 changes.clear()
 for a in people:
  for key in ["id","clan","gen","partner","friend"]:a[key]=int(a[key])
  a["sick"]=int(a.get("sick",0))
  a["prophet"]=bool(a.get("prophet",false))
  a["activity"]=str(a.get("activity","Esplora"))
 for v in villages:
  for key in ["era","houses","tech"]:v[key]=int(v[key])
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
 log_event("Risposta a "+a.name+": "+words[choice])
 return true
