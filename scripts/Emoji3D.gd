extends Node3D

@export var emojis = []

func reset_emojis():
	for i in emojis:
		get_node(i).hide()

func set_emoji(index):
	reset_emojis()
	get_node(emojis[index]).show()
