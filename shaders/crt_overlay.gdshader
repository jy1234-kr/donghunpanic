shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float scanline_strength = 0.12;
uniform float vignette_strength = 0.55;
uniform float darkness = 0.15;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(screen_texture, uv);
	float scanline = sin(uv.y * 480.0 * 3.14159) * scanline_strength;
	color.rgb -= scanline;
	color.rgb *= 1.0 - darkness;
	float dist = distance(uv, vec2(0.5));
	color.rgb *= 1.0 - dist * vignette_strength;
	color.r += dist * 0.04;
	COLOR = color;
}
