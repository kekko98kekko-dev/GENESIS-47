shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
varying vec3 wp;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n2(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){
 VERTEX.y+=sin(VERTEX.x*.31+TIME*.8)*.045+cos(VERTEX.z*.42-TIME*.63)*.035;
 wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment(){
 vec2 p=wp.xz;
 float q=n2(p*.12+vec2(TIME*.035,-TIME*.025));
 float r=sin(p.x*2.4+p.y*.61+q*5.0+TIME*.8)*.5+.5;
 float s=cos(p.x*.71-p.y*1.9+q*4.0-TIME*.65)*.5+.5;
 float f=pow(1.0-max(dot(NORMAL,VIEW),0.0),3.0);
 ALBEDO=mix(vec3(.012,.071,.102),vec3(.027,.164,.18),q);
 ALBEDO+=vec3(.025,.045,.046)*pow(r*s,4.0);
 ALBEDO=mix(ALBEDO,vec3(.19,.35,.39),f*.45);
 ROUGHNESS=.32;
 METALLIC=.05;
 NORMAL_MAP=vec3(.5+.035*(r-.5),.5+.035*(s-.5),1.0);
}
