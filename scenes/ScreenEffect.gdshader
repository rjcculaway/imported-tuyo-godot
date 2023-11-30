shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D distortion_texture;
uniform sampler2D caustics_texture;
uniform float wave_speed = 0.5f;
uniform float caustic_speed = 0.5f;
uniform float caustics_falloff = 1.5f;
uniform float distortion_falloff = 2.;

void fragment() {
	float scroll_x = fract(UV.x + TIME * wave_speed);
	vec2 distorted_uv = vec2(fract(scroll_x), UV.y);
	vec2 caustic_scroll_uv = vec2(UV.x, fract(UV.y + TIME * caustic_speed));
	vec3 noise_color = textureLod(distortion_texture, distorted_uv, 0.0).rgb;
	
	float caustics_fade = 1. - pow(length(vec2(UV.x - 0.5, UV.y)), caustics_falloff);
	float distortion_fade = pow(length(vec2(UV.x - 0.5, UV.y)), distortion_falloff);
	vec3 caustics_color = texture(caustics_texture, mix(caustic_scroll_uv, noise_color.rg, 0.025)).rgb * caustics_fade;
	
	vec3 c = textureLod(screen_texture, mix(SCREEN_UV, noise_color.rg, .025 * distortion_fade), 0.0).rgb;
	// Place fragment code here.
	COLOR = vec4(caustics_color + c, 1.0);
	// COLOR = vec4(distortion_fade);
	// COLOR = vec4(scroll_x, UV.y, 1.0, 1.0);
}
