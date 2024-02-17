extends AnimatedSprite3D

# On Ready
@onready var emoji = get_node("Emoji3D");
@onready var bubble : AnimatedSprite3D = get_node("Bubble")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")

# Variable
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var current_emoji
var active = false

# Show Emoji
func show_emoji():
	active = true
	current_emoji = randi_range(0, 7)
	emoji.set_emoji(current_emoji)
	emoji.show()
	bubble.show()
	bubble.play("good")

# Clear out emoji
func clear_emoji():
	active = false
	bubble.hide()
	emoji.hide()

# Check if emoji provided match with current
func check_for_match(emoji):
	if (active):
		var match = emoji == current_emoji
		var success = match
		if success:
			clear_emoji()
		return success
