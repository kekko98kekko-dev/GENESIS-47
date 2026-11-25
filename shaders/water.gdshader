shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
varying vec3 wp;
uniform float detail_strength = 1.0;
uniform sampler2D height_map : filter_linear, repeat_disable;
uniform sampler2D ocean_displacement : filter_linear, repeat_disable;
uniform bool ocean_simulation = false;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n2(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){
 vec2 ocean_uv=(VERTEX.xz+vec2(52.0))/104.0;
 if(ocean_simulation && all(greaterThanEqual(ocean_uv,vec2(0.0))) && all(lessThanEqual(ocean_uv,vec2(1.0)))){
  VERTEX.y+=texture(ocean_displacement,ocean_uv).r;
 }
 VERTEX.y+=sin(VERTEX.x*.31+TIME*.8)*.045+cos(VERTEX.z*.42-TIME*.63)*.035;
 wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment(){
 vec2 p=wp.xz;
 float q=n2(p*.12+vec2(TIME*.035,-TIME*.025));
 float r=sin(p.x*2.4+p.y*.61+q*5.0+TIME*.8)*.5+.5;
 float s=cos(p.x*.71-p.y*1.9+q*4.0-TIME*.65)*.5+.5;
 float f=pow(1.0-max(dot(NORMAL,VIEW),0.0),3.0);
 float ripples=n2(p*3.8+vec2(TIME*.13,-TIME*.09));
 ALBEDO=mix(vec3(.012,.071,.102),vec3(.027,.164,.18),q);
 ALBEDO+=vec3(.025,.045,.046)*pow(r*s,4.0);
 ALBEDO+=vec3(.020,.055,.052)*pow(ripples,3.0)*detail_strength;
 ALBEDO=mix(ALBEDO,vec3(.19,.35,.39),f*.45);
 vec2 hu=(p+vec2(53.0))/106.0;
 if(hu.x>0.0 && hu.x<1.0 && hu.y>0.0 && hu.y<1.0){
  float h=texture(height_map,hu).r*20.0-5.0;
  float d=max(0.0,-.4-h);
  float shoal=1.0-smoothstep(0.0,2.1,d);
  ALBEDO=mix(ALBEDO,vec3(.045,.31,.27),shoal*.68);
  float foam=1.0-smoothstep(.03,.22,abs(d-(.19+.10*sin(TIME*1.2+q*11.0))));
  ALBEDO=mix(ALBEDO,vec3(.63,.76,.69),foam*(.5+.5*q));
  float caustic=pow(abs(sin(p.x*3.3+p.y*2.2+q*4.0+TIME*.4)*cos(p.y*3.9-p.x*1.9-TIME*.32)),7.0);
  ALBEDO+=vec3(.09,.13,.08)*caustic*shoal*detail_strength;
  float wave_band=pow(max(0.0,sin(d*4.5-TIME*1.25+q*5.0)),9.0)*shoal;
  ALBEDO=mix(ALBEDO,vec3(.44,.67,.63),wave_band*.24*detail_strength);
 }
 ROUGHNESS=.32;
 METALLIC=.05;
 NORMAL_MAP=vec3(.5+.035*(r-.5),.5+.035*(s-.5),1.0);
}
