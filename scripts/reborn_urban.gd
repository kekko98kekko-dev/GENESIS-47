extends RefCounted
# Terrain-aware curved lanes; existing saved dwellings retain positions.
static func axes(w,clan:int)->Array:
 var c:Vector3=w.centers[clan]
 var other:Vector3=w.centers[1-clan]
 var along=Vector3(other.x-c.x,0,other.z-c.z).normalized()
 if along.length_squared()<.01:along=Vector3.RIGHT
 return [along,Vector3(-along.z,0,along.x)]
static func frontage(w,clan:int,p:Vector3)->Vector3:
 var a=axes(w,clan)
 var c:Vector3=w.centers[clan]
 var d=p-c
 var u=d.dot(a[0])
 var v=d.dot(a[1])
 var lane=roundf(v/7.4)*7.4
 var curve=.62*sin(u*.32+float(clan)*.8)
 var q:Vector3=c+a[0]*u+a[1]*(lane+curve)
 if absf(v-lane-curve)<.2:q=c
 return w.ground(q.x,q.z)
static func near_home(w,p:Vector3,r:float)->bool:
 for clan in range(2):
  for site in w.house_sites[clan]:
   if Vector2(p.x-float(site.x),p.z-float(site.z)).length()<r:return true
 return false
static func farm(w,clan:int,j:int)->Vector3:
 var a=axes(w,clan)
 var c:Vector3=w.centers[clan]
 var q:Vector3=c-a[0]*(6.6+float(j)*3.0)+a[1]*(5.5 if clan==0 else -5.5)
 return w.land_near(q.x,q.z)
static func plot(w,clan:int,j:int)->Vector3:
 var a=axes(w,clan)
 var c:Vector3=w.centers[clan]
 var lane=int(j/12)
 var index=j%12
 var along=(float(int(index/2))+1.0)*3.25+3.0
 if index%2==1:along=-along
 var row=ceili(float(lane+1)*.5)
 var lane_offset=float(row)*7.4*(1.0 if lane%2==0 else -1.0)
 var offset=lane_offset+(-2.3 if index%4<2 else 2.3)+.62*sin(along*.32+float(clan)*.8)
 var q:Vector3=c+a[0]*along+a[1]*offset
 q=w.ground(q.x,q.z)
 var limit=91.0 if w.vast_world else 46.0
 var usable=absf(q.x)<limit and absf(q.z)<limit and q.y>w.SEA+.85 and q.y<12 and w.away_from_route(q,2.1)
 usable=usable and w.flat_dist(q,c)<w.flat_dist(q,w.centers[1-clan])
 for i in range(2):
  if w.flat_dist(q,farm(w,clan,i))<3.1:usable=false
 for d in w.districts.districts:
  if w.flat_dist(q,Vector3(float(d.x),0,float(d.z)))<3.1:usable=false
 for dx in [-1.15,1.15]:
  for dz in [-1.15,1.15]:
   var h=float(w.height_at(q.x+dx,q.z+dz))
   if h<w.SEA+.55 or absf(h-q.y)>.85:usable=false
 if not usable and j>=96:
  var angle=float(j)*2.39996+clan*.5
  var radius=8.0+sqrt(float(j-96))*2.7
  q=w.ground(c.x+cos(angle)*radius,c.z+sin(angle)*radius)
  usable=absf(q.x)<limit and absf(q.z)<limit and q.y>w.SEA+.85 and w.away_from_route(q,2.1) and w.flat_dist(q,c)<w.flat_dist(q,w.centers[1-clan])
  for i in range(2):
   if w.flat_dist(q,farm(w,clan,i))<3.1:usable=false
  for d in w.districts.districts:
   if w.flat_dist(q,Vector3(float(d.x),0,float(d.z)))<3.1:usable=false
 if not usable:q.y=w.SEA-10
 return q
