shader_type canvas_item;

uniform vec4 base_color = vec4(1.0,1.0,1.0,1.0);
uniform sampler2D corona_texture : filter_nearest, repeat_enable;

uniform float aspect_ratio = 2.0;
uniform float rotation_speed = 0.3;
uniform bool as_shadow = false;

float circle(vec2 position, float radius, float feather) {
	return 1.0-smoothstep(radius, radius + feather, length(position-vec2(0.125)));
}

void fragment() {
	COLOR=base_color*circle(UV-0.38,0.08,0.5);
	// make sphere, cc0 code taken from https://godotshaders.com/shader/2d-spinning-sphere/
	float px = 4.5 * (UV.x - 0.5);
	float py = 4.5 * (UV.y - 0.5);
	
	if (px * px + py * py > 1.0) {
		// Outside of "sphere"
		COLOR.a = 0.0;
	} else {
		px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
		py = asin(py) * 2.0 / PI;
		
		COLOR = texture(TEXTURE, vec2(
			0.5 * (px + 1.0) / aspect_ratio - TIME * rotation_speed,
			0.5 * (py + 1.0)));
		if (as_shadow) {
			COLOR.rgb = vec3(0.0, 0.0, 0.0);
			COLOR.a *= 0.9;
		}
	}
	// modulate color based on temperature
	COLOR*=base_color*1.5;
	if (COLOR.g>1.25) {
		COLOR.rgb = vec3(1.25,1.25,1.25);
	}
	// apply corona
	if (COLOR.a==0.0) {
		// force additive because of hdr loop-around
		float alpha = circle(UV-0.38,0.20,0.1)-texture(corona_texture,UV+TIME*0.05).r;
		if (alpha>0.0) {
			COLOR.a += alpha;
		} 
		COLOR.rgb=texture(corona_texture,UV+TIME*0.05).rgb*base_color.rgb+0.5;
	}
}