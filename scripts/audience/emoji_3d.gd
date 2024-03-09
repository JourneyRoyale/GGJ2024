extends Node3D

@export var emojis = []
var current_index = 0

func reset_emojis():
	get_tree().call_group("AudienceManager", "delete_emoji", current_index)
	current_index = 0
	for i in emojis:
		get_node(i).hide()

func set_emoji(index):
	current_index = index
	get_node(emojis[index]).show()
	get_tree().call_group("AudienceManager", "add_emoji", index)
