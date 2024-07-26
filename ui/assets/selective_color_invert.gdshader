shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// areas of white and max alpha will appear as the inverse of background.

void fragment() {
	if (texture(TEXTURE,UV)==vec4(1.0,1.0,1.0,1.0)) {
		vec4 screen = texture(SCREEN_TEXTURE,SCREEN_UV);
		COLOR.rgb = 1.0-screen.rgb;
	}
	else {
		COLOR = texture(TEXTURE,UV);
	}
}