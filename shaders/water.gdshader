shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
varying vec3 wp;
void vertex(){
 VERTEX.y += sin(VERTEX.x*.31+TIME*1.1)*.075+cos(VERTEX.z*.42-TIME*.85)*.06;
 wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment(){
 float a=sin(wp.x*.48+wp.z*.20+TIME*.8);
 float b=cos(wp.x*.14-wp.z*.61+TIME*.6);
 float f=pow(1.0-max(dot(NORMAL,VIEW),0.0),3.0);
 float w=a*b*.5+.5;
 ALBEDO=mix(mix(vec3(.025,.19,.25),vec3(.08,.48,.46),w),vec3(.53,.78,.79),f*.55);
 ROUGHNESS=.23;
 METALLIC=.1;
 NORMAL_MAP=vec3(.5+.08*a,.5+.08*b,1.0);
}
