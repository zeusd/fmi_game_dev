shader_type canvas_item;

uniform bool active = false;
uniform bool passive = false;
uniform bool dont = false;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 og_color = texture(TEXTURE, UV);
	
	if (active) {
		COLOR = vec4(1.0 - og_color.rgb, og_color.a);
	}
	if (passive) {
		float oompf = dont ? 3.0 : 1.0;
		float avg = (og_color.r + og_color.g + og_color.b) / (oompf * 5.0);
		COLOR = vec4(avg, avg, avg, og_color.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
