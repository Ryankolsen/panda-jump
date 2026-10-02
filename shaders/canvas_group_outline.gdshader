// Outlines everything drawn inside a CanvasGroup — placeholder shapes and
// textures alike — by sampling the group's own rendered picture. Used on
// bamboo so it stands out from the green background whether it shows the
// placeholder or the artist's drawing.
//
// line_thickness is in real screen pixels; the owning script scales it by
// the window's stretch factor so the outline is the same thickness in game
// pixels on every screen size.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float line_thickness = 1.0;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1),
	vec2(0, 1), vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	vec2 size = line_thickness * SCREEN_PIXEL_SIZE;
	float outline = 0.0;
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(screen_texture, SCREEN_UV + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);

	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = mix(color, line_color, outline - color.a);
}
