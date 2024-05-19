shader_type canvas_item;

uniform vec4 base_color = vec4(1.0,1.0,1.0,1.0);
uniform float aspect_ratio = 1.0;
uniform float rotation_speed = 1.0;

// this is highly hack-y, but if this value takes the tangent of the PointLight2D faking the planets' lighting, it just works!
// also make sure celestial fake lights are in layer 2
uniform float light_direction_degrees = 0.0;

// specific to ocean layer
uniform float ocean_surface_coverage = 0.5;

vec4 tex_sphere(vec2 uv,vec4 color,sampler2D TEX) {
	// modified cc0 code from https://godotshaders.com/shader/2d-spinning-sphere/
	float px = 4.5 * (uv.x - 0.5);
	float py = 4.5 * (uv.y - 0.5);
	
	if (px * px + py * py > 1.0) {
		// Outside of "sphere"
		color.a = 0.0;
	} else {
		px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
		py = asin(py) * 2.0 / PI;
		
		vec4 tex = texture(TEX, vec2(
			0.5 * (px + 1.0) / aspect_ratio - TIME * rotation_speed*0.25,
			0.5 * (py + 1.0)));
		if (tex.r<=ocean_surface_coverage) {
			color = base_color*tex+0.25;
		}
		else {
			color.a = 0.0;
		}
	}
	return color;
}

vec3 norm_sphere(vec2 uv,vec3 norm,sampler2D map) {
	// modified cc0 code from https://godotshaders.com/shader/2d-spinning-sphere/
	float px = 4.5 * (uv.x - 0.5);
	float py = 4.5 * (uv.y - 0.5);
	
	if (px * px + py * py > 1.0) {
		// Outside of "sphere"
		norm = vec3(0.0,0.0,0.0);
	} else {
		px = asin(px / sqrt(1.0 - py * py)) * 2.0 / PI;
		py = asin(py) * 2.0 / PI;
	}
	norm = texture(map, vec2(
			0.5 * (px + 1.0) / aspect_ratio - TIME * rotation_speed*0.25,
			0.5 * (py + 1.0))).rgb;
	
	norm.r-=0.5*(cos(radians(light_direction_degrees))+1.0);
	norm.g-=0.5*(sin(radians(light_direction_degrees))+1.0);
	
	return norm;
}

void fragment() {
	COLOR = tex_sphere(UV,COLOR,TEXTURE);
	NORMAL = norm_sphere(UV,NORMAL,NORMAL_TEXTURE);
}

void light() {
	float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
}