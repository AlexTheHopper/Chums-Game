shader_type spatial;

uniform sampler2D albedo_tex;    // your mesh's diffuse texture
uniform sampler2D dissolve_noise;              // noise texture for dissolve
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base = texture(albedo_tex, UV);
    float noise_val = texture(dissolve_noise, UV).r;

    // create dissolve cutoff
    float alpha = step(dissolve_amount, noise_val);

    ALBEDO = base.rgb;
    ALPHA  = base.a * alpha;

    if (ALPHA < 0.01) {
        discard;
    }
}
