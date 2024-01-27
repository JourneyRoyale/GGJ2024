extends Button

func _on_pressed():
	print("Start Game button clicked!!!")
	var animation_player = get_parent().get_node("AnimationPlayer")
	if animation_player != null:
		animation_player.play("curtains_open")
