shader_type canvas_item;

void fragment() {
	COLOR.a = float(int(UV.x * 100.0) % 2);
}
