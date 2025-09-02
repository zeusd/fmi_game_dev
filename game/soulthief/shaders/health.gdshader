shader_type canvas_item;

uniform float fill_percent: hint_range(0.0, 1.0, 0.1) = 1.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	COLOR.a *= step(0.75 - fill_percent * 0.53, 1.42 - UV.x - (9.0/16.0) * UV.y);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
