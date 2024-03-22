extends Area3D
class_name Projectile

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")

# Local Variable
var speed : int
var projectile : Dictionary

# Initial setup
var is_at_clamped_height = false
var clamped_y_position = 1.0
var adjust_speed = 5 # Speed at which the projectile adjusts its y position

#Boomerang
var returnTrip = false;
var target_speed = speed # Target speed for smooth interpolation
var smooth_turn_duration = 0.5 # Duration of the turn in seconds
var smooth_turn_timer = 0.0 # Timer to track the interpolation progress

func _ready() -> void :
	speed = projectile["speed"]
	target_speed = projectile["speed"]

# Calculate position using speed and adjust y position if needed
func _process(delta : float) -> void :
	# Check and initiate return trip
	if position.z > 0 and not returnTrip and projectile["type"] == Shared.E_ProjectileType.BOOMERANG:
		returnTrip = true
		target_speed = -speed # Set the target speed for the return trip
		smooth_turn_timer = smooth_turn_duration # Reset the timer for smooth turn
		
	# Smoothly interpolate speed if in the process of turning
	if returnTrip and smooth_turn_timer > 0:
		smooth_turn_timer -= delta # Decrement the timer
		var t = 1 - smooth_turn_timer / smooth_turn_duration # Calculate interpolation factor
		var current_speed = lerp(speed, target_speed, t) # Interpolate speed
		position.z += current_speed * delta
	else:
		position.z += target_speed * delta # Proceed with target speed
	
	# Adjust y position smoothly to the clamped value
	if not is_at_clamped_height:
		position.y = lerp(position.y, clamped_y_position, adjust_speed * delta)
		if abs(position.y - clamped_y_position) < 0.05:
			position.y = clamped_y_position
			is_at_clamped_height = true

# Check for player collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided(projectile)
		queue_free()
