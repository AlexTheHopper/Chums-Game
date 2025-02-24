shader_type spatial;
render_mode depth_test_disabled;

uniform sampler2D my_texture; // ViewportTexture from SubViewport

void fragment() {
    vec4 color = texture(my_texture, UV);

    // Use the ViewportTexture as the sprite's texture
    ALBEDO = color.rgb;
    ALPHA = color.a; // Preserve the original transparency
}