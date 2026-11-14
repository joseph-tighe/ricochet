shader_type canvas_item;

// Mosaic a sprite: retro looks, censor blocks, transitions. `amount` is the block size in texels.
uniform float amount : hint_range(1.0, 32.0) = 8.0;
uniform vec2 sheet_frames = vec2(1.0, 1.0);   // a sprite sheet: its hframes and vframes, so the blocks start at each frame's corner

varying vec4 vertex_tint;   // modulate and self_modulate, applied at the end

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 grid = TEXTURE_PIXEL_SIZE * amount;
	vec2 uv = floor(UV / grid) * grid + grid * 0.5;
	if (sheet_frames != vec2(1.0)) {
		// blocks counted from the corner of each frame (from the sheet's they shifted from
		// frame to frame), and the last one of a frame never samples the next frame
		vec2 frame_px = (1.0 / TEXTURE_PIXEL_SIZE) / sheet_frames;
		vec2 cell = min(floor(UV * sheet_frames), sheet_frames - 1.0);
		vec2 local_px = UV / TEXTURE_PIXEL_SIZE - cell * frame_px;
		vec2 centre = min(floor(local_px / amount) * amount + amount * 0.5, frame_px - 0.5);
		uv = (cell * frame_px + centre) * TEXTURE_PIXEL_SIZE;
	}
	COLOR = textureLod(TEXTURE, uv, 0.0);   // (no blurred line at each block edge with mipmaps)
	COLOR *= vertex_tint;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
