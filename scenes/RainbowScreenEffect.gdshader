shader_type canvas_item;

uniform float rainbow_opacity: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest, repeat_disable;
uniform sampler2D noise_texture;
uniform sampler2D rainbow_texture;
uniform mediump float falloff: hint_range(0.0, 10.0) = 1.0;
uniform mediump float falloff_scale = 1.0;
uniform lowp float flower_wave_speed = 1.0;
uniform lowp float color_cycle_speed = 1.0;
uniform lowp float distortion_strength: hint_range(0.0, 1.0) = 0.05;

uniform lowp float petal_limit: hint_range(0.0, 1.0, 0.05) = 0.25;
uniform lowp float num_of_petals = 10.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 base_uv = vec2(UV);
	base_uv -= 0.5;
	base_uv *= 2.;
	
	float angle = atan(base_uv.y, base_uv.x);
	
	float flowers[3] = float[3] ( 
		sin((angle + TIME * flower_wave_speed) * num_of_petals), 
		sin((angle + TIME * 0.25 * flower_wave_speed + PI) * num_of_petals / 2.), 
		sin((angle + TIME * 0.15 * flower_wave_speed + 3. * PI / 4.) * num_of_petals * 2.) 
	);
	
	float flower_y = 0.0;
	
	// Combine all the waves
	for (int i = 0; i < 3; i++) {
		flower_y += flowers[i];
	}
	
	float dist = length(vec2(base_uv.x, base_uv.y + petal_limit * flower_y) * falloff_scale);
	
	float rotating_angle = mod(TIME * color_cycle_speed + angle, 2. * PI);
	
	vec2 polar_uv = vec2(rotating_angle, dist) / (2. * PI);
	// COLOR = vec4(texture(noise_texture, vec2(UV.x, UV.y + .25 * sin(UV.x * 2. * PI))));
	
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 rainbow_color = texture(rainbow_texture, polar_uv);
	COLOR = vec4(rainbow_color.rgb + screen_color.rgb, pow(dist, falloff) * rainbow_opacity);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
