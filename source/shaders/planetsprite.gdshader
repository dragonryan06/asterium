shader_type canvas_item;

uniform vec4 base_color = vec4(1.0,1.0,1.0,1.0);
uniform float aspect_ratio = 2.0;
uniform float rotation_speed = 1.0;
uniform bool as_shadow = false;

uniform vec4 ocean_color = vec4(0.0,0.0,0.0,1.0);
uniform float ocean_coverage = 0.0;

void fragment() {
	// make sphere, cc0 code taken from https://godotshaders.com/shader/2d-spinning-sphere/
	float px = 4.5 * (UV.x - 0.5);
	float py = 4.5 * (UV.y - 0.5);
	
	if (px * px + py * py > 1.0) {
		// Outside of "sphere"
		COLOR.a = 0.0;
	} else {
		px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
		py = asin(py) * 2.0 / PI;
		
		vec4 tex = texture(TEXTURE, vec2(
			0.5 * (px + 1.0) / aspect_ratio - TIME * rotation_speed*0.25,
			0.5 * (py + 1.0)));
		if (tex.r>ocean_coverage || ocean_coverage==0.0) {
			COLOR = tex*base_color;
		}
		else {
			COLOR = mix(ocean_color,tex,tex.r);
		}
		
		if (as_shadow) {
			COLOR.rgb = vec3(0.0, 0.0, 0.0);
			COLOR.a *= 0.9;
		}
	}
	// lighten black
	if (COLOR.r<0.5 && COLOR.g<0.5 && COLOR.b<0.5) {
		COLOR.rgb+=vec3(0.1,0.1,0.1);
	}
}
