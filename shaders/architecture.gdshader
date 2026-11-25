shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color=vec4(.65,.56,.44,1.);
uniform float masonry=0.0;
uniform float roofing=0.0;
varying vec3 p;
varying vec3 w;
void vertex(){
 p=VERTEX;
 w=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
}
float hash(vec2 v){return fract(sin(dot(v,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec3 n=abs(normalize(NORMAL));
 vec2 face=n.x>n.z?w.zy:w.xy;
 if(n.y>max(n.x,n.z))face=w.xz;
 vec2 brick=face*vec2(4.6,7.0);
 brick.x+=floor(brick.y)*.5;
 vec2 cell=fract(brick);
 float seam=max(1.-smoothstep(.025,.07,min(cell.x,1.-cell.x)),1.-smoothstep(.025,.07,min(cell.y,1.-cell.y)));
 float board=1.-smoothstep(.025,.075,abs(fract(face.y*7.)-.5));
 float grain=hash(floor(face*40.));
 vec3 base=base_color.rgb*(.88+.19*hash(floor(brick))+.04*grain);
 base=mix(base,base*.68,seam*masonry*.75);
 base=mix(base,base*.72,board*roofing*.6);
 ALBEDO=base;
 ROUGHNESS=.90-roofing*.18;
 SPECULAR=.2;
}
