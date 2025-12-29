shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_width = 0.03;

void vertex() {
    // Convert to view space
    vec4 view_pos = VIEW_MATRIX * vec4(VERTEX, 1.0);

    // Push away from the camera
    view_pos.xyz += normalize(view_pos.xyz) * outline_width;

    // Convert back to object space
    VERTEX = (INV_VIEW_MATRIX * view_pos).xyz;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
