class_name CardDatabase
extends Node

# The @export_dir hint gives you a nice folder picker in the Godot inspector
@export_dir var cards_directory: String = "res://commons/cards/database/cards"

# Our final, globally accessible registry mapping string IDs to CommandCards
var card_registry: Dictionary = {}

func _ready() -> void:
	_load_cards_from_directory(cards_directory)
	print("Total Cards Loaded: ", card_registry.size())
	print("Available Card IDs: ", card_registry.keys())
	
func _load_cards_from_directory(path: String) -> void:
	# Safely ensure the path string ends with a trailing slash
	if not path.ends_with("/"):
		path += "/"
		
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open cards directory: " + path)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		# Ensure we are looking at a file, not a nested subfolder
		if not dir.current_is_dir():
			# We check for both standard text resources and remapped binary versions
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
				# Clean up the file path (crucial for export builds)
				var clean_file_name = file_name.trim_suffix(".remap")
				var full_path = path + clean_file_name
				
				var card = load(full_path) as CommandCard
				if card:
					if card.id == "":
						push_error("Card Database Error: Card has an empty ID string at: " + full_path)
					else:
						card_registry[card.id] = card
				else:
					push_error("Card Database Error: Failed to load resource at: " + full_path)
					
		file_name = dir.get_next()
		
	dir.list_dir_end()

func get_card(card_id: String) -> CommandCard:
	if card_registry.has(card_id):
		return card_registry[card_id]
	push_error("Card ID not found in database: " + card_id)
	return null
