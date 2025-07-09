shader_type spatial;

varying float y;

void vertex() {
	// Called for every vertex the material is visible on.
	y = VERTEX.y;
}

void fragment() {
	ALBEDO = COLOR.rgb; //* mix(0.1, 0.9, y);
}
