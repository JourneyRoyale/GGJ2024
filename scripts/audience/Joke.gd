extends Node3D
class_name Joke

# Egg look at camera
func _process(delta : float) -> void :
	get_tree().call_group("Camera", "look_at_camera", self)
