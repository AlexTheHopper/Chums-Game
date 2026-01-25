shader_type spatial;
render_mode unshaded, cull_front;

uniform sampler2D depth_tex : hint_depth_texture, repeat_disable;
uniform float outline_thickness : hint_range(0.0, 3.0, 0.01);
uniform float step_threshold : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec3 outline_color : source_color = vec3(0.0, 0.0, 0.0);

float DepthVS(vec2 uv, mat4 inv_proj_mat) {
	float depth = texture(depth_tex, uv).r;
	return 1. / (depth * inv_proj_mat[2].w + inv_proj_mat[3].w);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1, 1);
}

void fragment() {
	float thickness = outline_thickness * 0.001;
	float depth = DepthVS(SCREEN_UV, INV_PROJECTION_MATRIX);
	float border_r = DepthVS(SCREEN_UV + vec2(thickness, 0), INV_PROJECTION_MATRIX) - depth;
	float border_l = DepthVS(SCREEN_UV - vec2(thickness, 0), INV_PROJECTION_MATRIX) - depth;
	float border_u = DepthVS(SCREEN_UV + vec2(0, thickness), INV_PROJECTION_MATRIX) - depth;
	float border_d = DepthVS(SCREEN_UV - vec2(0, thickness), INV_PROJECTION_MATRIX) - depth;
	float outline = clamp(border_r + border_l + border_u + border_d, 0, 1);
	outline = smoothstep(0, step_threshold, outline);
	ALBEDO = outline * outline_color;
	ALPHA = outline;
}