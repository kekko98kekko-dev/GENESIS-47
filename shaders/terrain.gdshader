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
 ALBEDO=COLOR.rgb*(.48+grain*.80+patches);
 ALBEDO*=mix(vec3(.96,1.03,.94),vec3(1.06,.98,.89),noise2(wp.xz*1.2));
 ALBEDO*=season_tint.rgb;
 ALBEDO*=.91+fine*.18;
 float micro=noise2(wp.xz*18.0);
 float macro=noise2(wp.xz*.24);
 ALBEDO*=mix(.73,1.14,macro);
 ALBEDO*=mix(.90,1.08,micro);
 float moss=noise2(wp.xz*1.6+vec2(47.0,13.0));
 ALBEDO=mix(ALBEDO,ALBEDO*vec3(.76,.96,.77),smoothstep(.47,.79,moss)*.6);
 float slope=1.0-abs(dot(normalize(NORMAL),normalize((VIEW_MATRIX*vec4(0.0,1.0,0.0,0.0)).xyz)));
 ALBEDO=mix(ALBEDO,vec3(.38,.40,.36),smoothstep(.26,.62,slope)*.40);
 float strata=noise2(vec2(wp.y*4.0,wp.x*.23+wp.z*.18));
 ALBEDO=mix(ALBEDO,ALBEDO*(.76+strata*.35),smoothstep(.28,.68,slope)*.55);
 ROUGHNESS=mix(.97,.84,smoothstep(.25,.70,slope));
}
