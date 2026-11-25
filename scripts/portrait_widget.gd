extends Control
# A lightweight animated identification portrait, using the selected person's
# inherited proportions, color, age and current emotion. Not a stock avatar.
var citizen:Dictionary={}
var phase=0.0
func set_person(a:Dictionary):
 citizen=a
 visible=not a.is_empty()
 queue_redraw()
func _process(dt:float):
 if not is_visible_in_tree():return
 phase+=dt
 queue_redraw()
func _draw():
 if citizen.is_empty():return
 var center=Vector2(size.x*.5,size.y*.5)
 var genes:Array=citizen.genes
 var clan=int(citizen.clan)
 var tint=Color("398f85").lerp(Color("a7d7b2"),float(genes[2])) if clan==0 else Color("a66342").lerp(Color("e9b981"),float(genes[2]))
 draw_rect(Rect2(0,0,size.x,size.y),Color("1a353a"))
 draw_circle(center,43,Color("29494b"))
 var width=1.0+.26*float(genes[1])-.25*float(genes[3])
 var height=.90+.30*float(genes[3])
 var face=center+Vector2(0,-2+sin(phase*2)*1.2)
 draw_set_transform(face,0,Vector2(width,height))
 draw_circle(Vector2.ZERO,32,tint)
 for side in [-1,1]:
  draw_colored_polygon(PackedVector2Array([Vector2(side*24,-7),Vector2(side*41,-23),Vector2(side*31,12)]),tint.darkened(.16))
  if float(genes[1])>.58:
   draw_colored_polygon(PackedVector2Array([Vector2(side*17,-25),Vector2(side*30,-47),Vector2(side*27,-19)]),Color("e6d4b0"))
  var blink=.13 if fposmod(phase+float(citizen.id)*.7,4.3)<.13 else 1.0
  draw_set_transform(face+Vector2(side*12,-6),0,Vector2(1,blink))
  draw_circle(Vector2.ZERO,9,Color("eee4ce"))
  draw_circle(Vector2(0,1),5,Color("487b72").lerp(Color("98714d"),float(genes[2])))
  draw_circle(Vector2(0,1),2.8,Color("172e30"))
  draw_circle(Vector2(-1.6,-1.5),1.3,Color.WHITE)
 draw_set_transform(face,0,Vector2(width,height))
 var mood=float(citizen.mood)
 var curve=4 if mood>70 else -3 if mood<40 else 0
 draw_polyline(PackedVector2Array([Vector2(-7,12),Vector2(0,12+curve),Vector2(7,12)]),tint.darkened(.48),2.0,true)
 if float(citizen.age)>55:
  draw_arc(Vector2(0,17),14,0,PI,14,Color("dadbd0"),5,true)
 if int(citizen.get("scars",0))>0:draw_line(Vector2(17,8),Vector2(22,17),Color("85685b"),2,true)
 draw_set_transform(Vector2.ZERO)
