shader_type canvas_item;
void fragment(){
 float alpha=.86*(1.0-smoothstep(.30,1.0,UV.x));
 COLOR=vec4(.025,.055,.065,alpha);
}
