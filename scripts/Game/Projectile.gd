extends Area3D

# On Ready
@onready var game_manager = get_node("/root/GameManager")
@onready var audio_manager = get_node("/root/AudioManager")

# Export
@export var SPEED = 10

# Calculate position using speed
func _process(delta):
	position.z += SPEED * delta

# Check for player collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided()
		body.position.z += 1
		queue_free()
