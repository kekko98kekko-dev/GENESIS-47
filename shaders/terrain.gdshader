shader_type spatial;
render_mode diffuse_burley;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise2(vec2 p){vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f); return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 float grain=noise2(wp.xz*3.0)*.14+noise2(wp.xz*13.0)*.06;
 ALBEDO=COLOR.rgb*(.68+grain*.85);
 ROUGHNESS=.97;
}
