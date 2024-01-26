shader_type canvas_item;

uniform vec4 color = vec4(1.0,1.0,0.75,1.0);
uniform float energy = 0.75;
uniform float rotSpeed = 1.0;
uniform vec2 rotDirection = vec2(1.0,0.0);
uniform float coronaRadius = 1.0;
uniform sampler2D coronaTexture : repeat_enable;
uniform sampler2D surfaceTexture : repeat_enable;
uniform sampler2D curve;

float circle(vec2 position, float radius, float feather) {
	return 1.0-smoothstep(radius, radius + feather, length(position-vec2(0.125)));
}

void fragment() {
	vec2 vecToCenter = vec2(0.125, 0.125) - UV;
	float distToCenter = length(vecToCenter);
	float curveVal = texture(curve, vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter)*0.9*curveVal;
	vec4 star = vec4(circle(UV-diff, 0.1, 0.0025))*texture(surfaceTexture,vec2(UV.x + TIME * rotSpeed*0.01, UV.y))*color;
	float glow = circle(UV-diff,0.001,0.4);
	float corona = 0.0;
	if (star.a<1.0) {
		corona = circle(UV-diff,0.035*coronaRadius,0.1)*texture(coronaTexture,vec2(UV.x + TIME * rotSpeed*0.02, UV.y)).r*2.0;
	}
	COLOR = star+vec4(2.0*color.r,2.0*color.g,2.0*color.b,glow)/2.0*energy+corona;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
