// This is a Quake 3 Arena shader file, it will work in Q3 and other games that use that engine.
// Don't be weird and expect it to work for anything else whatsoever ;)
// Find and replace [yourshadernamehere] with something more appropriate for your map


// Gives treadplate floor metalsteps param
textures/[yourshadernamehere]/floor_treadplate_clang
{
	qer_editorimage textures/[yourshadernamehere]/floor_treadplate.tga
	surfaceparm metalsteps

	{
		map textures/[yourshadernamehere]/floor_treadplate.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
}

// Gives treadplate floor metalsteps param
textures/[yourshadernamehere]/floor_slabsTreadplate_clang
{
	qer_editorimage textures/[yourshadernamehere]/floor_slabsTreadplate.tga
	surfaceparm metalsteps

	{
		map textures/[yourshadernamehere]/floor_slabsTreadplate.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
}

// Metalsteps transparent grill
textures/[yourshadernamehere]/metal_gridTrans
{
	qer_editorimage textures/[yourshadernamehere]/metal_gridTrans.tga
	surfaceparm metalsteps
	surfaceparm trans
	cull none

	{
		map textures/[yourshadernamehere]/metal_gridTrans.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
		depthfunc equal
	}
}

// Bouncepad
// Bouncepad shader timings are identical to Q3A bouncepads
textures/[yourshadernamehere]/bounce_cement_dark
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cement_dark.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cement_dark.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Bouncepad
textures/[yourshadernamehere]/bounce_cement
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cement.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cement.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Bouncepad
textures/[yourshadernamehere]/bounce_treadplate
{
	qer_editorimage textures/[yourshadernamehere]/bounce_treadplate.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	surfaceparm metalsteps
	
	{
		map textures/[yourshadernamehere]/bounce_treadplate.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Bouncepad
textures/[yourshadernamehere]/bounce_metal
{
	qer_editorimage textures/[yourshadernamehere]/bounce_metal.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_metal.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Bouncepad
textures/[yourshadernamehere]/bounce_hexes
{
	qer_editorimage textures/[yourshadernamehere]/bounce_hexes.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_hexes.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Bouncepad
textures/[yourshadernamehere]/bounce_hexrhombus
{
	qer_editorimage textures/[yourshadernamehere]/bounce_hexrhombus.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_hexrhombus.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// CTF Bouncepad
textures/[yourshadernamehere]/bounce_cement_red
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cement_red.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring_red.tga
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cement_red.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow_red.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring_red.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// CTF Bouncepad
textures/[yourshadernamehere]/bounce_cement_blue
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cement_blue.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring_blue.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cement_blue.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow_blue.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring_blue.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// CTF Bouncepad
textures/[yourshadernamehere]/bounce_cementdark_red
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cementdark_red.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring_red.tga	
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cementdark_red.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow_red.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring_red.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// CTF Bouncepad
textures/[yourshadernamehere]/bounce_cementdark_blue
{
	qer_editorimage textures/[yourshadernamehere]/bounce_cementdark_blue.tga
	q3map_lightimage textures/[yourshadernamehere]/bounce_ring_blue.tga
	q3map_surfacelight 400
	surfaceparm nodamage
	
	{
		map textures/[yourshadernamehere]/bounce_cementdark_blue.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
	}
	{
		map textures/[yourshadernamehere]/bounce_glow_blue.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .5 .5 0 1.5	
	}
	{
		clampmap textures/[yourshadernamehere]/bounce_ring_blue.tga
		blendfunc GL_ONE GL_ONE
		tcMod stretch sin 1.2 .8 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

// Fluorescent light 2k light val
textures/[yourshadernamehere]/light_vert1_2k
{
	qer_editorimage textures/[yourshadernamehere]/light_vert1.tga
	q3map_lightimage textures/[yourshadernamehere]/light_vert1blend.tga
	surfaceparm nomarks
	q3map_surfacelight 2000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Fluorescent light 5k light val
textures/[yourshadernamehere]/light_vert1_5k
{
	qer_editorimage textures/[yourshadernamehere]/light_vert1.tga
	q3map_lightimage textures/[yourshadernamehere]/light_vert1blend.tga
	surfaceparm nomarks
	q3map_surfacelight 5000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Fluorescent light 10k light val
textures/[yourshadernamehere]/light_vert1_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_vert1.tga
	q3map_lightimage textures/[yourshadernamehere]/light_vert1blend.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_vert1blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_arc_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_arc.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_arc.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_arc.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_arc.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_arc_8k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_arc.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_arc.tga
	surfaceparm nomarks
	q3map_surfacelight 8000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_arc.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_arc.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_blue_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_blue.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_blue.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_blue.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_blue.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_blue_8k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_blue.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_blue.tga
	surfaceparm nomarks
	q3map_surfacelight 8000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_blue.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_blue.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_pink_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_pink.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_pink.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_pink.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_pink.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_pink_8k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_pink.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_pink
	q3map_surfacelight 8000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_pink.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_pink.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_red_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_red.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_red.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_red.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_red.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_red_8k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_red.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_red.tga
	surfaceparm nomarks
	q3map_surfacelight 8000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_red.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_red.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_yellow_10k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_yellow.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_yellow.tga
	surfaceparm nomarks
	q3map_surfacelight 10000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_yellow.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_yellow.tga
		blendfunc GL_ONE GL_ONE
	}
}

// Small ceiling light
textures/[yourshadernamehere]/light_ceil_yellow_8k
{
	qer_editorimage textures/[yourshadernamehere]/light_ceil_yellow.tga
	q3map_lightimage textures/[yourshadernamehere]/light_glow_yellow.tga
	surfaceparm nomarks
	q3map_surfacelight 8000

	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_ceil_yellow.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/[yourshadernamehere]/light_glow_yellow.tga
		blendfunc GL_ONE GL_ONE
	}
}

