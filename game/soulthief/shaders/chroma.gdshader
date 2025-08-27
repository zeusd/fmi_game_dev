shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float offset = 1.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 green_channel = texture(screen_texture, SCREEN_UV);
	vec4 red_channel = texture(screen_texture, vec2(SCREEN_UV.x + (offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	vec4 blue_channel = texture(screen_texture, vec2(SCREEN_UV.x - (offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
