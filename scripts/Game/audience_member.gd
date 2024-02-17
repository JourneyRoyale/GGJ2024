extends AnimatedSprite3D

@onready var label = get_node("Label3D")
@onready var emoji = get_node("Emoji3D");
@onready var bubble : AnimatedSprite3D = get_node("Bubble")

var current_emoji

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var active = false

@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")

func show_emoji():
	active = true
	current_emoji = randi_range(0, 7)
	emoji.set_emoji(current_emoji)
	emoji.show()
	bubble.show()
	bubble.play("good")

func clear_emoji():
	active = false
	bubble.hide()
	emoji.hide()
		
func check_for_match(emoji):
	if (active):
		var match = emoji == current_emoji
		var success = match
		if success:
			clear_emoji()
		return success
