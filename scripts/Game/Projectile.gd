extends Area3D

@export var SPEED = 0.01
@onready var game_manager = get_node("/root/GameManager")
@onready var audio_manager = get_node("/root/AudioManager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.z += SPEED

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided()
		body.position.z += 1
		game_manager.register_hit()
