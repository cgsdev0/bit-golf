shader_type canvas_item;

void fragment() {
	COLOR.a = clamp(-sign(distance(UV, vec2(0.5)) - 0.5) + sign(distance(UV, vec2(0.5)) - 0.3), 0.0, 1.0);
	vec2 d = (UV - vec2(0.5)) * 2.0;
	COLOR.a *= clamp(1.0 - atan(d.y / d.x * 1.5) * (sign(d.x + d.y) + 1.0), 0.0, 1.0);
	COLOR.a = round(COLOR.a) * 0.5;
}
