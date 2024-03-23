extends Area3D
class_name Projectile

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")

# Local Variable
var speed : int
var projectile : Dictionary
var enabled = false
var throw_type

# Initial setup
var is_at_clamped_height = false
var clamped_y_position = 1.0
var clamped_hover_position = 15
var adjust_speed = 5 # Speed at which the projectile adjusts its y position


#Boomerang
var returnTrip = false;
var target_speed = speed # Target speed for smooth interpolation
var smooth_turn_duration = 0.5 # Duration of the turn in seconds
var smooth_turn_timer = 0.0 # Timer to track the interpolation progress

# State Variables used by certain types of projectiles
var vertical_speed : float = 0.0
var initial_vertical_speed : float = 10.0
var destroy_timer: Timer
var hover_timer: Timer
var is_hovering: bool = false
var done_hovering: bool = false


func setProjectile(projectileInstance) -> void :
	projectile = projectileInstance
	speed = projectile["speed"]
	target_speed = projectile["speed"]
	throw_type = projectile["throw"]
	
	if throw_type == Shared.E_ThrowType.UNDERHAND:
		vertical_speed = initial_vertical_speed		
		speed = randi_range(5, 7)
		destroy_timer = Timer.new() # Create a new Timer
		destroy_timer.wait_time = 3 # Set timer to 3 seconds
		destroy_timer.one_shot = true # Ensure the timer only runs once
		add_child(destroy_timer) # Add the timer to the scene tree
		var destroy_callable = Callable(self, "_on_destroy_timer_timeout") # Create a Callable for the timeout method
		destroy_timer.connect("timeout", destroy_callable) # Connect the timer's timeout signal
		
	if throw_type == Shared.E_ThrowType.OVERHAND:
		speed = randi_range(4, 7)
		
		destroy_timer = Timer.new() # Create a new Timer
		destroy_timer.wait_time = 3 # Set timer to 3 seconds
		destroy_timer.one_shot = true # Ensure the timer only runs once
		add_child(destroy_timer) # Add the timer to the scene tree
		var destroy_callable = Callable(self, "_on_destroy_timer_timeout") # Create a Callable for the timeout method
		destroy_timer.connect("timeout", destroy_callable) # Connect the timer's timeout signal
		
		hover_timer = Timer.new() # Create a new Timer
		hover_timer.wait_time = 3 # Set timer to 3 seconds
		hover_timer.one_shot = true # Ensure the timer only runs once
		add_child(hover_timer) # Add the timer to the scene tree
		var hover_callable = Callable(self, "_on_hover_timer_timeout") # Create a Callable for the timeout method
		hover_timer.connect("timeout", hover_callable) # Connect the timer's timeout signal

	enabled = true

#
## Calculate position using speed and adjust y position if needed
func _process(delta : float) -> void :
	if enabled:
		var is_boomerang = projectile["type"] == Shared.E_ProjectileType.BOOMERANG
		if throw_type == Shared.E_ThrowType.SLING:
			_sling_behavior(delta, is_boomerang)
		if throw_type == Shared.E_ThrowType.UNDERHAND:
			_underhand_behavior(delta)
			
		if throw_type == Shared.E_ThrowType.OVERHAND:
			_overhand_behavior(delta)


# Check for player collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.projectile_collided(projectile)
		queue_free()

func _sling_behavior(delta : float, is_boomerang: bool):
			## Check and initiate return trip
		if position.z > 0 and not returnTrip and is_boomerang:
			_subtype_boomerang_behavior()
			#
		## Smoothly interpolate speed if in the process of turning
		if returnTrip and smooth_turn_timer > 0:
			smooth_turn_timer -= delta # Decrement the timer
			var t = 1 - smooth_turn_timer / smooth_turn_duration # Calculate interpolation factor
			var current_speed = lerp(speed, target_speed, t) # Interpolate speed
			position.z += current_speed * delta
		else:
			position.z += target_speed * delta # Proceed with target speed
		#
		## Adjust y position smoothly to the clamped value
		if not is_at_clamped_height:
			position.y = lerp(position.y, clamped_y_position, adjust_speed * delta)
			if abs(position.y - clamped_y_position) < 0.05:
				position.y = clamped_y_position
				is_at_clamped_height = true
				
func _underhand_behavior(delta : float):
	var gravity : float = -9.8
	# Gravity strength for underhhand
	 # Apply gravity to vertical speed
	vertical_speed += gravity * delta
	 # Update position
	position.y += vertical_speed * delta

	# Check if reached or passed the target height, then clamp
	if position.y <= clamped_y_position:
		position.y = clamped_y_position
		vertical_speed = 0 # Optionally stop vertical movement
		if not destroy_timer.is_stopped():
			destroy_timer.start() # Start the destroy timer if not already running
	else:
		position.z += speed * delta  # Assuming forward movement is along the z-axis


				
func _overhand_behavior(delta : float):
	var gravity : float = -20.0 # Assuming a stronger gravity for faster descent

	if not is_hovering and position.y < clamped_hover_position and position.y > clamped_y_position:
		# Initial ascent or descent phase
		if not done_hovering:
			# Ascent phase: Reverse gravity's effect to 'push' upwards
			vertical_speed += (-gravity * delta) # Invert gravity's direction for the ascent
		else:
			# Descent phase: Apply gravity normally
			vertical_speed += gravity * delta

		position.y += vertical_speed * delta
		# Continue moving forward while rising or falling
		if not done_hovering:
			position.z += speed * delta

	elif not is_hovering and position.y >= clamped_hover_position and not done_hovering:
		# Reached hover position, initiate hovering
		is_hovering = true
		vertical_speed = 0  # Neutralize vertical speed to simulate hovering
		position.y = clamped_hover_position  # Clamp to hover position
		hover_timer.start()  # Begin hover period

	if position.y <= clamped_y_position and done_hovering:
		# After hovering, ensure it doesn't go below the clamped position
		position.y = clamped_y_position
		vertical_speed = 0  # Stop any vertical movement
		if not destroy_timer.is_stopped():
			destroy_timer.start()  # Cleanup after reaching the target

func _subtype_boomerang_behavior():
	returnTrip = true
	target_speed = -speed # Set the target speed for the return trip
	smooth_turn_timer = smooth_turn_duration # Reset the timer for smooth turn
	
	
func _on_destroy_timer_timeout():
	queue_free() # Destroy the projectile
	
func _on_hover_timer_timeout():
	is_hovering = false
	done_hovering = true
	position.y = 10
	position.z = randi_range(-3, 1)
	
