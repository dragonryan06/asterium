shader_type canvas_item;

uniform sampler2D density;
uniform sampler2D brightness;
uniform float size = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 position = floor(1.0 / size * FRAGCOORD.xy);
	
	float densemap = texture(density,UV).r;
	float brightmap = texture(brightness,UV).r*2.0;
	
	float star_density = 0.025*densemap;
	float color_warp = random(vec2(random(UV)*random(position),random(vec2(position)*random(vec2(UV)))));
	
	vec4 output;
	
	float star_val = random(position);
	if (star_val<star_density) {
		output = vec4(1.0,1.0,1.0,1.0)*brightmap*random(UV);
		if (color_warp>0.5 && color_warp<0.85) {
			output.b*=0.25*random(UV);
		}
		else if (color_warp>0.85 && color_warp<0.9) {
			output.g*=0.25;
			output.b*=0.25;
		}
		else if (color_warp>0.9) {
			output.r*=0.25;
			output.g*=0.75;
		}
	}
	else {
		output = vec4(0.0,0.0,0.0,1.0);
	}
	vec4 final = output+star_density*8.0*brightmap;
	if (output==vec4(0.0,0.0,0.0,1.0)) {
		final.b*=0.85;
	}
	else {
		final-=sin(TIME*random(UV)*8.0)*random(UV)/4.0;
	}
	COLOR = final;
}