shader_type canvas_item;

uniform sampler2D texture2 : repeat_enable;
uniform vec2 scroll1 = vec2(0.02, 0.02);
uniform vec2 scroll2 = vec2(0.01, 0.01);
uniform float offset_time = 1;

void fragment() {
	vec4 textureColor1 = texture(TEXTURE, UV + scroll1 * sin(offset_time * TIME));
	vec4 textureColor2 = texture(texture2, UV + scroll2 * cos(offset_time * TIME));
	vec4 energy = textureColor1 * textureColor2;
	COLOR = energy;
}