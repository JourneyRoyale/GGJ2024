extends Area3D

# On Ready
@onready var game_manager = get_node("/root/Game_Manager")
@onready var audio_manager = get_node("/root/Audio_Manager")

# Export
@export var SPEED = 10

var clamped_y_position = 1.0
var adjust_speed = 5 # Speed at which the projectile adjusts its y position

# Initial setup
var is_at_clamped_height = false

# Calculate position using speed and adjust y position if needed
func _process(delta):
	position.z += SPEED * delta
	
	# Check if we need to adjust the y position
	if not is_at_clamped_height:
		position.y = lerp(position.y, clamped_y_position, adjust_speed * delta)
		
		# Check if the projectile is close enough to the clamped y position
		if abs(position.y - clamped_y_position) < 0.05:
			position.y = clamped_y_position
			is_at_clamped_height = true

# Check for player collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided()
		body.position.z += 1
		queue_free()
