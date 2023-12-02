shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = vec2(UV);
	float angle = atan(uv.y, uv.x);
	
	float waves[3] = float[3] (
		(0.005 * sin(uv.x * 2. * PI * 5. + TIME + 11.)),
		(0.025 * cos(uv.x * 2. * PI * 10. + TIME * 0.5 - 15.)),
		(0.05 * sin(uv.x * 2. * PI * 15. + TIME * 2.))
	);
	
	for (int i = 0; i < 3; i++) {
		uv.y += waves[i] * (1.0 - UV.y);
	}
	vec4 color = texture(TEXTURE, uv);
	COLOR = color;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
