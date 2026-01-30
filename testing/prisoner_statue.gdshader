shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;

uniform vec4 albedo;
uniform sampler2D texture_albedo;

uniform vec4 emission_color = vec4(1.0);
uniform float emission_amount = 1.0;

uniform sampler2D dissolve_texture;
uniform float burn_size : hint_range(0.0, 2.0) = 0.1;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float sample = texture(dissolve_texture, UV).r;

	float emission_value = 1.0 - smoothstep(
		dissolve_amount,
		dissolve_amount + burn_size,
		sample
	);

	EMISSION = emission_color.rgb * emission_value * emission_amount;

	ALPHA = clamp(
		smoothstep(
			dissolve_amount - burn_size,
			dissolve_amount,
			sample
		),
		0.0,
		1.0
	);
}
