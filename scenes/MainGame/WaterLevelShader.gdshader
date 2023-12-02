shader_type canvas_item;

uniform float water_depth: hint_range(0.0, .9);

const vec4 WHITE = vec4(1.0);

void fragment() {
	vec4 texture_color = texture(TEXTURE, vec2(water_depth, 1.0));
	COLOR = texture_color;	// Place fragment code here.
}
