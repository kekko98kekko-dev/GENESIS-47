extends RefCounted
# Original procedural score; no sample libraries, downloads or streaming.
var calm:AudioStreamPlayer
var tense:AudioStreamPlayer
var weather:AudioStreamPlayer
var world
var enabled=false
var ambience:AudioStreamPlayer
var voice:AudioStreamPlayer
var voice_clock=0.0
var ambient_city:AudioStreamWAV
var ambient_nature:AudioStreamWAV

func setup(w):
 world=w
 calm=AudioStreamPlayer.new()
 tense=AudioStreamPlayer.new()
 weather=AudioStreamPlayer.new()
 ambience=AudioStreamPlayer.new()
 voice=AudioStreamPlayer.new()
 for p in [calm,tense,weather,ambience,voice]:
  w.add_child(p)
  p.volume_db=-60
 calm.stream=score(false)
 tense.stream=score(true)
 weather.stream=rain()
 ambient_city=ambient(true)
 ambient_nature=ambient(false)
 ambience.stream=ambient_nature
 for p in [calm,tense,weather,ambience]:p.play()
 enabled=true

func wav(data:PackedByteArray,rate:int,frames:int)->AudioStreamWAV:
 var stream=AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=rate
 stream.data=data
 stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
 stream.loop_end=frames
 return stream

func score(danger:bool)->AudioStreamWAV:
 var rate=16000
 var duration=24.0
 var frames=int(duration*rate)
 var data=PackedByteArray()
 data.resize(frames*2)
 var chords=[[130.81,164.81,196.00],[110.00,130.81,164.81],[87.31,130.81,174.61],[98.00,146.83,196.00]]
 var dark=[[98.00,116.54,146.83],[87.31,110.00,130.81],[82.41,98.00,130.81],[73.42,98.00,116.54]]
 for i in range(frames):
  var t=float(i)/rate
  var bar=int(t/6)%4
  var chord:Array=(dark if danger else chords)[bar]
  var phase=fposmod(t,6.0)
  var envelope=sin(PI*phase/6.0)
  var sample_value=0.0
  for j in range(3):
   var f=float(chord[j])
   sample_value+=(sin(TAU*f*t)*.038+sin(TAU*f*2*t)*.007)*envelope
  var beat=fposmod(t,1.5)
  var note=float(chord[int(t/1.5)%3])*2
  sample_value+=sin(TAU*note*beat)*exp(-beat*3.2)*minf(1.0,beat*30)*.055
  if danger:sample_value+=sin(TAU*49*beat)*exp(-beat*5)*minf(1.0,beat*40)*.08
  var edge=minf(1.0,minf(t,duration-t)*5.0)
  data.encode_s16(i*2,clampi(int(sample_value*edge*30000),-32767,32767))
 return wav(data,rate,frames)

func rain()->AudioStreamWAV:
 var rate=16000
 var frames=rate*5
 var data=PackedByteArray()
 data.resize(frames*2)
 var rng=RandomNumberGenerator.new()
 rng.seed=4781
 var low=0.0
 for i in range(frames):
  var value=rng.randf_range(-1.0,1.0)
  low=lerpf(low,value,.07)
  var edge=minf(1.0,minf(float(i),float(frames-i))/400)
  data.encode_s16(i*2,int((value*.032+low*.13)*edge*28000))
 return wav(data,rate,frames)

func update(dt:float):
 if not enabled:return
 var muted=world.audio.stream_paused
 var gain=linear_to_db(maxf(.001,float(world.volume_value)/100.0))
 var risk=clampf((45.0-float(world.sim.peace))/45.0,0,1)
 if not world.sim.active_crisis.is_empty() or not world.hazards.is_empty():risk=maxf(.7,risk)
 var rainy=world.sim.weather_name in ["Pioggia","Neve"]
 calm.volume_db=lerpf(calm.volume_db,-70.0 if muted else gain-16-28*risk,clampf(dt*.7,0,1))
 tense.volume_db=lerpf(tense.volume_db,-70.0 if muted else gain-44+28*risk,clampf(dt*.7,0,1))
 weather.volume_db=lerpf(weather.volume_db,gain-14 if rainy and not muted else -70,clampf(dt,0,1))
 world.audio.volume_db=-70
 var in_city=false
 for p in world.centers:
  if world.flat_dist(world.focus,p)<10 and world.distance<30:in_city=true
 var desired=ambient_city if in_city else ambient_nature
 if ambience.stream!=desired:ambience.stream=desired;ambience.play()
 ambience.volume_db=lerpf(ambience.volume_db,gain-21 if not muted else -70,clampf(dt,0,1))
 voice_clock=maxf(0,voice_clock-dt)
 if not muted and voice_clock<=0 and world.speed>0 and world.distance<15:
  for a in world.sim.people:
   if a.task_stage=="In corso" and a.task in ["social","teach","aid"] and world.actors.has(a.id) and world.flat_dist(world.actors[a.id].node.position,world.focus)<4:
    voice.stream=chirp(int(a.id),float(a.genes[3]))
    voice.volume_db=gain-11
    voice.play()
    voice_clock=3.0
    break


func ambient(city:bool)->AudioStreamWAV:
 var rate=12000
 var frames=rate*6
 var bytes=PackedByteArray()
 bytes.resize(frames*2)
 var rng=RandomNumberGenerator.new()
 rng.seed=470 if city else 147
 var low=0.0
 for i in range(frames):
  var t=float(i)/rate
  var noise=rng.randf_range(-1,1)
  low=lerpf(low,noise,.04)
  var sample_value=low*.09
  if city:
   var beat=fposmod(t,1.33)
   sample_value+=sin(TAU*124*beat)*exp(-beat*18)*minf(beat*60,1)*.045
   sample_value+=sin(TAU*220*t)*sin(TAU*.19*t)*.008
  else:
   var beat=fposmod(t,2.13)
   if beat<.19:sample_value+=sin(TAU*(1300*beat+300*beat*beat))*sin(PI*beat/.19)*.045
  var edge=minf(1,minf(t,6-t)*8)
  bytes.encode_s16(i*2,int(clampf(sample_value*edge,-1,1)*26000))
 return wav(bytes,rate,frames)

func chirp(id:int,voice_trait:float)->AudioStreamWAV:
 var rate=12000
 var frames=int(rate*.65)
 var bytes=PackedByteArray()
 bytes.resize(frames*2)
 for i in range(frames):
  var t=float(i)/rate
  var beat=fposmod(t,.21)
  var f=270+voice_trait*240+float(posmod(id+int(t/.21),4))*45
  var envelope=sin(PI*minf(1.0,beat/.18)) if beat<.18 else 0.0
  var sample_value=(sin(TAU*f*beat)+sin(TAU*f*2.05*beat)*.23)*envelope*.10
  bytes.encode_s16(i*2,int(sample_value*28000))
 var clip=wav(bytes,rate,frames)
 clip.loop_mode=AudioStreamWAV.LOOP_DISABLED
 return clip
