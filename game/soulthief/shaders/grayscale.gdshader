shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float brightness: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float contrast: hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float saturation: hint_range(-10.0, 10.0, 0.01) = 1.0;

mat4 bri_mat(float b) {
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)
	);
}

mat4 con_mat(float c) {
	float t = (1.0 - c) / 2.0;
	return mat4(
		vec4(c, 0, 0, 0),
		vec4(0, c, 0, 0),
		vec4(0, 0, c, 0),
		vec4(t, t, t, 1)
	);
}

mat4 sat_mat(float s) {
	vec3 lum = vec3(0.3086, 0.6094, 0.0820);
	float sr = (1.0 - s) * lum.r;
	float sg = (1.0 - s) * lum.g;
	float sb = (1.0 - s) * lum.b;
	return mat4(
		vec4(sr + s, sr, sr, 0),
		vec4(sg, sg + s, sg, 0),
		vec4(sb, sb, sb + s, 0),
		vec4(0, 0, 0, 1)
	);
}

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	//vec4 bg = texture(screen_texture, SCREEN_UV);
	//float avg = (bg.r + bg.g + bg.b) /3.0;
	//COLOR = vec4(avg, avg, avg, 0.5);
	
	vec4 color = texture(screen_texture, UV);
	mat4 mat = bri_mat(brightness) * con_mat(contrast) * sat_mat(saturation);
	COLOR = mat * color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
