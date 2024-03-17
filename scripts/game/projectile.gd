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

enum ProjectileType {
	Tomato,
	Boomerang,
	Brick
}

var type: ProjectileType = ProjectileType.Tomato

#Variables for more dynamic projectile types

#Boomerang
var returnTrip = false;


var target_speed = SPEED # Target speed for smooth interpolation
var smooth_turn_duration = 0.5 # Duration of the turn in seconds
var smooth_turn_timer = 0.0 # Timer to track the interpolation progress

# Calculate position using speed and adjust y position if needed
func _process(delta):
	# Check and initiate return trip
	if position.z > 0 and not returnTrip and type == ProjectileType.Boomerang:
		returnTrip = true
		target_speed = -SPEED # Set the target speed for the return trip
		smooth_turn_timer = smooth_turn_duration # Reset the timer for smooth turn
		
	# Smoothly interpolate speed if in the process of turning
	if returnTrip and smooth_turn_timer > 0:
		smooth_turn_timer -= delta # Decrement the timer
		var t = 1 - smooth_turn_timer / smooth_turn_duration # Calculate interpolation factor
		var current_speed = lerp(SPEED, target_speed, t) # Interpolate speed
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
		var is_brick = type == ProjectileType.Brick
		body.projectile_collided(is_brick)
		body.position.z += 1
		queue_free()
