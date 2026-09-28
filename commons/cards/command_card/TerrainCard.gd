class_name TerrainCard
extends Resource

@export_group("Command Card Properties")
@export var id: String = ""
@export var title_label: String = ""
@export var effect_label: String = ""
@export_multiline var description_label: String = ""
@export var infantry_negate_count: String = ""
@export var tank_negate_count: String = ""

@export_group("Visuals")
@export_file("*.png", "*.webp", "*.jpg")
var card_art_path: String = ""

@export_file("*.png", "*.webp", "*.jpg")
var infantry_art: String = ""

@export_file("*.png", "*.webp", "*.jpg")
var tank_art: String = ""

func load_card_art(art_type: String, sprite_index: int = 1) -> Texture2D:
	var art_path := ""

	match art_type:
		"card":
			art_path = card_art_path
		"infantry":
			if infantry_art.is_empty():
				return null
			return load(infantry_art) as Texture2D
		"tank":
			if tank_art.is_empty():
				return null
			return load(tank_art) as Texture2D
		_:
			return null

	if art_path.is_empty():
		return null

	var texture := load(art_path) as Texture2D

	if texture == null:
		return null

	# Sprite index is 1-7
	if sprite_index < 1 or sprite_index > 7:
		return null

	var sprite_count := 7

	# Convert to zero-based index internally.
	var index := sprite_index - 1

	var start_x := floori(
		float(index) * texture.get_width() / sprite_count
	)

	var end_x := floori(
		float(index + 1) * texture.get_width() / sprite_count
	)

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		start_x,
		0,
		end_x - start_x,
		texture.get_height()
	)
	return atlas
