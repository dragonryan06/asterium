shader_type canvas_item;

group_uniforms camera_properties;
// size property of object this material belongs to
uniform vec2 resolution = vec2(1.0,1.0);
// offset in global coords
uniform vec2 offset = vec2(0.0,0.0);
uniform vec2 zoom = vec2(0.0,0.0);

group_uniforms lines;
uniform float half_thickness = 0.001;
// global coords
uniform float radial_period = 64;
uniform int first_radius_drawn = 0;
uniform int last_radius_drawn = 1;

vec2 scale_by_aspect(float ratio, vec2 what) {
	return vec2((what.x-0.5)*ratio+0.5,what.y);
}

float circle(vec2 position, float radius) {
	return step(radius,length(position - vec2(0.5))+half_thickness*2.0)*step(length(position - vec2(0.5)), radius);
}

void fragment() {
	vec2 z = zoom;
	if (zoom==vec2(0.0,0.0)) {
		z = vec2(1.0,1.0);
	}
	float ratio = resolution.x/resolution.y;
	vec2 proportional_uv = scale_by_aspect(ratio,UV);
	vec2 pos = proportional_uv+scale_by_aspect(ratio,offset)*SCREEN_PIXEL_SIZE*z;
	vec2 zoom_pos = proportional_uv+scale_by_aspect(ratio,offset)*SCREEN_PIXEL_SIZE;
	if (pos.y>0.5-half_thickness && pos.y<0.5+half_thickness || pos.x>0.5-half_thickness && pos.x<0.5+half_thickness) {
		// axes
		COLOR = vec4(0.0,0.0,1.0,1.0);
	}
	else {
		// backdrop
		COLOR = vec4(0.0,0.0,0.0,0.0);
		// circular radii
		for (int i=first_radius_drawn;i<last_radius_drawn;i++) {
			float circ = circle(pos,1.75*z.x*(radial_period+(radial_period*float(i)))*SCREEN_PIXEL_SIZE.x);
			COLOR += vec4(0.0,0.0,circ,circ);
		}
	}
}