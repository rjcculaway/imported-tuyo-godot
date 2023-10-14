shader_type canvas_item;

uniform vec2 offset = vec2(0.5f, 0.5f);

void fragment() {
	vec2 radial_uv = vec2(length(UV - offset), atan(UV.y, UV.x));
	
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec2 ratio = pixel_size.x > pixel_size.y ? vec2(pixel_size.y / pixel_size.x, 1) : vec2(1, pixel_size.x / pixel_size.y);
	
	COLOR = texture(TEXTURE, radial_uv * ratio);
	// Place fragment code here.
}
