shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_disabled;
varying float tip;
varying float variation;
void vertex(){
 vec3 center=(MODEL_MATRIX*vec4(0.0,0.0,0.0,1.0)).xyz;
 tip=clamp(VERTEX.y*3.5,0.0,1.0);
 variation=fract(sin(dot(center.xz,vec2(127.1,311.7)))*43758.5453);
 VERTEX.x+=sin(TIME*1.6+center.x*.42+center.z*.28)*tip*.09;
 VERTEX.z+=cos(TIME*1.3+center.z*.32)*tip*.055;
}
void fragment(){
 vec3 low=mix(vec3(.14,.25,.075),vec3(.22,.33,.09),variation);
 vec3 high=mix(vec3(.33,.48,.14),vec3(.60,.61,.22),variation);
 ALBEDO=mix(low,high,tip);
 ROUGHNESS=1.0;
}
