shader_type spatial;
render_mode diffuse_burley;
varying vec3 wp;
uniform vec4 season_tint : source_color = vec4(1.0);
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise2(vec2 p){vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 float grain=noise2(wp.xz*3.0)*.14+noise2(wp.xz*13.0)*.06;
 float patches=noise2(wp.xz*.45)*.17;
 float fine=noise2(wp.xz*27.0);
 ALBEDO=COLOR.rgb*(.60+grain*.85+patches);
 ALBEDO*=mix(vec3(.96,1.03,.94),vec3(1.06,.98,.89),noise2(wp.xz*1.2));
 ALBEDO*=season_tint.rgb;
 ALBEDO*=.92+fine*.16;
 float slope=1.0-abs(dot(normalize(NORMAL),normalize((VIEW_MATRIX*vec4(0.0,1.0,0.0,0.0)).xyz)));
 ALBEDO=mix(ALBEDO,vec3(.29,.30,.25),smoothstep(.26,.62,slope)*.40);
 ROUGHNESS=.97;
}
