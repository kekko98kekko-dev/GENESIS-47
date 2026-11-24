shader_type spatial;
render_mode diffuse_burley;
uniform vec4 skin_color : source_color = vec4(.3,.7,.6,1.0);
varying vec3 local_pos;
void vertex(){local_pos=VERTEX;}
void fragment(){
 vec3 p=local_pos;
 float m=sin(p.x*25.0+sin(p.z*11.0)*1.4)*sin(p.y*23.0+sin(p.x*12.0));
 float spots=smoothstep(.73,.97,m);
 float gradient=smoothstep(-.5,.48,p.y);
 ALBEDO=skin_color.rgb*(.88+.17*gradient);
 ALBEDO=mix(ALBEDO,skin_color.rgb*.69,spots*.25);
 ROUGHNESS=.64+spots*.12;
 SPECULAR=.28;
}
