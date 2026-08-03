shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 p = UV - vec2(0.5);
    
    // Make the circle slightly smaller to avoid clipping
    float circle = step(length(p), 0.5);

    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(tex.rgb, tex.a * circle);
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
