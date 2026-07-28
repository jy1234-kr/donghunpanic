shader_type spatial;
render_mode diffuse_toon, specular_disabled, cull_back;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 albedo_color : source_color = vec4(1.0);

varying vec3 v_normal;

void vertex() {
	v_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	vec3 base = (tex * albedo_color).rgb;
	float ndl = max(dot(normalize(v_normal), normalize(vec3(0.2, 1.0, 0.3))), 0.0);
	float bands = floor(ndl * 4.0) / 4.0;
	ALBEDO = base * (0.5 + bands * 0.5);
}
