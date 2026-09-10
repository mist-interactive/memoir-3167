shader_type canvas_item;

uniform float ellipse_size = 1.0;

void fragment() {
    vec2 uv = UV;

    vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 p = (uv - vec2(0.5)) * size;

    float rx = size.x * 0.5 * ellipse_size;
    float ry = size.y * 0.5 * ellipse_size;

    float ellipse =
        (p.x * p.x) / (rx * rx) +
        (p.y * p.y) / (ry * ry);

    COLOR = texture(TEXTURE, uv) * COLOR;

    // Inverted ellipse
    if (ellipse < 1.0) {
        COLOR.a = 0.0;
    }
}