shader_type canvas_item;

uniform float flash_progress: hint_range(0.0, 1.0);

const vec4 WHITE = vec4(1.0);

vec3 flash(vec3 color, float progress) {
	return mix(color, WHITE.rgb, progress);
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 flashed_color = vec4(flash(texture_color.rgb, flash_progress), texture_color.a);
	COLOR = flashed_color;	// Place fragment code here.
}
