shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec3 wp;
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 float grain=n(wp.xz*8.)*.26+n(wp.xz*1.7)*.17;
 ALBEDO=mix(vec3(.31,.21,.12),vec3(.62,.46,.29),grain+.38);
 ROUGHNESS=.98;
}
