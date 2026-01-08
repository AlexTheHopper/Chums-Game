shader_type canvas_item;

uniform float outline_thickness: hint_range(0.0, 16.0, 1.0) = 1.0;
uniform vec4 outline_color: source_color = vec4(1.0);

// Helper: ensure UV is inside texture
bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

void fragment() {
	vec2 uv = UV;
	vec4 tex = texture(TEXTURE, uv);

	//-----------------------------------
	// If this pixel is part of the silhouette,
	// DO NOT draw it (only outlines should appear)
	//-----------------------------------

	float mask_alpha = tex.a;

	//-----------------------------------
	// If this is a solid pixel → output transparent
	//-----------------------------------
	// (But we cannot return, so we store this)
	float output_alpha = 0.0;
	vec3 output_color = vec3(0.0);

	if (mask_alpha <= 0.0) {
		//-----------------------------------
		// This is a transparent pixel → SEARCH for outline
		//-----------------------------------

		float found_alpha = 0.0;
		vec2 ps = TEXTURE_PIXEL_SIZE;

		for (float y = 1.0; y <= outline_thickness; y++) {
			for (float x = 0.0; x <= y; x++) {

				vec2 offsets[8] = {
					vec2(x, y), vec2(-x, y),
					vec2(x, -y), vec2(-x, -y),
					vec2(y, x), vec2(-y, x),
					vec2(y, -x), vec2(-y, -x)
				};

				for (int i = 0; i < 8; i++) {
					vec2 sample_uv = uv + offsets[i] * ps;
					if (is_inside_usquare(sample_uv)) {
						float a = texture(TEXTURE, sample_uv).a;
						found_alpha = max(found_alpha, a);
					}
				}
			}
		}

		// If we found a silhouette nearby → this pixel IS outline
		if (found_alpha > 0.0) {
			output_color = outline_color.rgb;
			output_alpha = outline_color.a;
		}
	}

	//-----------------------------------
	// Output final
	//-----------------------------------
	COLOR = vec4(output_color, output_alpha);
}
