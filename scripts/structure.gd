extends RefCounted
# Four load-bearing supports plus roof. Damage is spatial and cumulative.
static func normalize(site:Dictionary):
 if not site.get("supports") is Array or site.supports.size()!=4:site["supports"]=[100.0,100.0,100.0,100.0]
 for i in range(4):site.supports[i]=clampf(float(site.supports[i]),0,100)
 site["roof"]=clampf(float(site.get("roof",100)),0,100)

static func integrity(site:Dictionary)->float:
 normalize(site)
 var total=0.0
 for v in site.supports:total+=float(v)
 return total*.20+float(site.roof)*.20

static func stress(site:Dictionary,origin:Vector3,damage:float,kind:String,era:int)->bool:
 normalize(site)
 var center=Vector2(float(site.x),float(site.z))
 var source=Vector2(origin.x,origin.z)
 var resistance=1.0+float(era)*.12
 var multiplier=1.0
 if kind=="Incendio":multiplier=1.6
 elif kind=="Tsunami" or kind=="Alluvione":multiplier=1.25
 elif kind=="Terremoto":multiplier=1.5
 var force=damage*multiplier/resistance
 for i in range(4):
  var offset=Vector2(-1 if i%2==0 else 1,-1 if i<2 else 1)
  var exposure=1.0+clampf(center.distance_to(source)-(center+offset).distance_to(source),-1,1)*.25
  site.supports[i]=maxf(0,float(site.supports[i])-force*exposure)
 site.roof=maxf(0,float(site.roof)-force*.8)
 var failures=0
 for v in site.supports:
  if float(v)<18:failures+=1
 if failures>0:
  for i in range(4):
   if float(site.supports[i])>=18:site.supports[i]=maxf(0,float(site.supports[i])-force*.18*failures)
 return failures>=2 or integrity(site)<22 or damage>=105

static func repair(site:Dictionary,wood:float)->float:
 normalize(site)
 if integrity(site)>=99 or wood<2:return 0.0
 for i in range(4):site.supports[i]=minf(100,float(site.supports[i])+8)
 site.roof=minf(100,float(site.roof)+6)
 return 2.0
