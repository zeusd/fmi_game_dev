shader_type spatial;
uniform float strength: hint_range(0.0, 1.0, 0.01) = 0.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	ALBEDO = vec3(0.8, 0.6, 0.0);
	ALPHA = strength;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
