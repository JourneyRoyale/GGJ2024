extends Node2D

# Export
@export var emojis = []

# Hide Current Emoji
func reset_emojis():
	for i in emojis:
		get_node(i).hide()

# Set Emoji Visible
func set_emoji(index):
	reset_emojis()
	get_node(emojis[index]).show()
