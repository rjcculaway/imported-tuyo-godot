shader_type canvas_item;

uniform vec4 star_color: source_color = vec4(1.0);
uniform lowp float star_intensity: hint_range(0.0, 1.0) = 0.125;
uniform lowp float star_falloff = 1.;
uniform uint num_of_stars = 5;
uniform lowp float x_offset: hint_range(-1.0, 1.0) = 0.0;
uniform lowp float y_offset: hint_range(-1.0, 1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 base_uv = (UV - 0.5) * 2.;
	
	base_uv.x += x_offset;
	base_uv.y += y_offset;
	
	float angle = atan(base_uv.y, base_uv.x);
	float radius = length(base_uv / (1.5 * sin(TIME) + 2.5));
	
	vec2 polar_uv = vec2(radius, angle) / 2. * PI;
	
	float stripes = star_intensity * clamp(sin(angle * float(num_of_stars) + TIME * 0.5), 0.0, 1.0);
	
	vec4 sky_color = texture(TEXTURE, UV);
	COLOR = vec4(sky_color);
	
	float falloff = pow(max(0.0, 1. - radius), star_falloff);
	
	vec4 star = (vec4(vec3(stripes) * falloff, 1.0)) * star_color;
	COLOR = vec4(sky_color.rgb, 1.0) + star;
	//COLOR = vec4(1.- vec3(radius), 1.0);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
