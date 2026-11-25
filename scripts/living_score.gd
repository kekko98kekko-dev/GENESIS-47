extends RefCounted
# Original procedural score; no sample libraries, downloads or streaming.
var calm:AudioStreamPlayer
var tense:AudioStreamPlayer
var weather:AudioStreamPlayer
var world
var enabled=false

func setup(w):
 world=w
 calm=AudioStreamPlayer.new()
 tense=AudioStreamPlayer.new()
 weather=AudioStreamPlayer.new()
 for p in [calm,tense,weather]:
  w.add_child(p)
  p.volume_db=-60
 calm.stream=score(false)
 tense.stream=score(true)
 weather.stream=rain()
 for p in [calm,tense,weather]:p.play()
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
