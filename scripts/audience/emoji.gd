extends Node3D
class_name Emoji

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var emoji_dictionary : Dictionary = {
	Shared.E_Emoji.ALCOHOL : get_node("Alcohol"),
	Shared.E_Emoji.CHICKEN : get_node("Chicken"),
	Shared.E_Emoji.CHICKEN_DRUMSTICK : get_node("Chicken Drumstick"),
	Shared.E_Emoji.CIGAR : get_node("Cigar"),
	Shared.E_Emoji.HEART : get_node("Heart"),
	Shared.E_Emoji.KNIFE : get_node("Knife"),
	Shared.E_Emoji.MONEY_BAG : get_node("Money Bag"),
	Shared.E_Emoji.SKULL : get_node("Skull"),
}

# Init variable
var valid_emoji : Array[Shared.E_Emoji]

# Local variable
var current_emoji : Shared.E_Emoji

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource
	
	valid_emoji = level_resource.emoji_list
	for emoji_enum : Shared.E_Emoji in emoji_dictionary.keys():
		if not (level_resource.emoji_list.has(emoji_enum)):
			emoji_dictionary[emoji_enum].queue_free()
			emoji_dictionary.erase(emoji_enum)

func _ready():
	_init_resources()

func reset_emojis() -> void :
	for emoji in get_children():
		emoji.hide()

func set_emoji(emoji : Shared.E_Emoji) -> void :
	reset_emojis()
	emoji_dictionary[emoji].show()
	current_emoji = emoji

func set_random_emoji_variety(chosen_emoji : Array[Shared.E_Emoji]) -> void :
	reset_emojis()
	var random_emoji : Shared.E_Emoji = chosen_emoji[game_manager.rng.randi_range(0, chosen_emoji.size() - 1)]
	emoji_dictionary[random_emoji].show()
	current_emoji = random_emoji

func set_random_emoji() -> void :
	reset_emojis()
	var random_emoji : Shared.E_Emoji = valid_emoji[game_manager.rng.randi_range(0, get_children().size() - 1)]
	emoji_dictionary[random_emoji].show()
	current_emoji = random_emoji

func check_match(emoji : Shared.E_Emoji) -> bool :
	return current_emoji == emoji
