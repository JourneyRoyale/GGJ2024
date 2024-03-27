extends Area3D
class_name Projectile

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var despawn_timer : Timer = get_node("Despawn Timer")
@onready var hover_timer : Timer = get_node("Hover Timer")
@onready var time_step_timer : Timer = get_node("Time Step Timer")

# Resource Variable
var projectile : Dictionary
var speed : int

# Init Variable
var throw_type : Shared.E_THROW_TYPE
var reterive_position : Vector3
var target_position : Vector3
var middle_clamped_point : Vector3
var direction : Vector3

# Local Variable
var time_step : float = .001
var trajectory_points : Array = []
var current_point_index : int = 0
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
var is_hovering: bool = false
var done_hovering: bool = false

func init_variable( projectile : Dictionary, throw_type : Shared.E_THROW_TYPE, target_position : Vector3, reterive_position : Vector3) :
	self.projectile = projectile
	self.throw_type = throw_type
	self.target_position = target_position
	self.reterive_position = reterive_position
	speed = projectile["speed"]
	target_speed = projectile["speed"]
	
	match throw_type:
		Shared.E_THROW_TYPE.UNDERHAND:
			vertical_speed = initial_vertical_speed #unsure
			speed = randi_range(5, 7) # unsure
		Shared.E_THROW_TYPE.OVERHAND:
			speed = randi_range(4, 7)

func _ready():
	_set_mesh_projectile()
	_set_clamped_height_point()
	_set_direction_to_target
	#_caculate_sling_trajectory()
	#print(trajectory_points)
	#time_step_timer.start(time_step)

func _process(delta : float) -> void :
	if throw_type == Shared.E_THROW_TYPE.SLING:
		_sling_behavior(delta)
	if throw_type == Shared.E_THROW_TYPE.UNDERHAND:
		_underhand_behavior(delta)
	if throw_type == Shared.E_THROW_TYPE.OVERHAND:
		_overhand_behavior(delta)

# From starting position determine at what position projectile should clamped to height
func _set_clamped_height_point() -> void :
	var point1 : Vector3 = global_transform.origin
	var point2 : Vector3 = target_position
	var target_y : float = target_position.y
	var target_z : float = -4.0
	
	# Calculate the interpolation factor based on the Z-coordinate of the point you're looking for
	var t : float = (target_z - point1.z) / (point2.z - point1.z)
	# Interpolate between the X coordinates of the two points
	var x : Variant = lerp(point1.x, point2.x, t)

	middle_clamped_point = Vector3(x, target_y, target_z)

# Set direction to target
func _set_direction_to_target() -> void :
	direction = (target_position - global_transform.origin).normalized()

func _set_mesh_projectile() -> void :
	match projectile["type"]:
		Shared.E_PROJECTILE_TYPE.TOMATO:
			get_node("Tomato").visible = true
		Shared.E_PROJECTILE_TYPE.BANANNA:
			get_node("Bananna").visible = true
		Shared.E_PROJECTILE_TYPE.BOOT:
			get_node("Boot").visible = true
		Shared.E_PROJECTILE_TYPE.BOOMERANG:
			get_node("Boomerang").visible = true
		Shared.E_PROJECTILE_TYPE.BRICK:
			get_node("Rock").visible = true
		Shared.E_PROJECTILE_TYPE.MONEY:
			get_node("Money").visible = true

# Logic for throw in a line
func _sling_behavior(delta : float) -> void :
	## Check and initiate return trip
	if position.z > 0 and not returnTrip and projectile["type"] == Shared.E_PROJECTILE_TYPE.BOOMERANG:
		returnTrip = true
		target_speed = -speed # Set the target speed for the return trip
		smooth_turn_timer = smooth_turn_duration # Reset the timer for smooth turn
	
	## Smoothly interpolate speed if in the process of turning
	if returnTrip and smooth_turn_timer > 0:
		smooth_turn_timer -= delta # Decrement the timer
		var t = 1 - smooth_turn_timer / smooth_turn_duration # Calculate interpolation factor
		var current_speed = lerp(speed, target_speed, t) # Interpolate speed
		position.z += current_speed * delta
	else:
		position.z += target_speed * delta # Proceed with target speed
	
	## Adjust y position smoothly to the clamped value
	if not is_at_clamped_height:
		position.y = lerp(position.y, clamped_y_position, adjust_speed * delta)
		if abs(position.y - clamped_y_position) < 0.05:
			position.y = clamped_y_position
			is_at_clamped_height = true

# Logic for throwing at an angle
func _underhand_behavior(delta : float) -> void :
	var firing_angle = 45.0
	var gravity = 9.8
	# Calculate distance to target
	var target_distance : float = global_transform.origin.distance_to(target_position)

	var projectile_velocity = target_distance / (sin(2 * deg_to_rad(firing_angle)) / gravity)
	
	# Extract the X  Y componenent of the velocity
	var Vx = sqrt(projectile_velocity) * cos(deg_to_rad(firing_angle))
	var Vy = sqrt(projectile_velocity) * sin(deg_to_rad(firing_angle))

	# Calculate flight time.
	var flight_duration = target_distance / Vx

	if(position.y <= 1):
		position.y = 1
		if despawn_timer.is_stopped():
			despawn_timer.start(projectile["despawn_time"])
	else:
		translate(Vector3(0, (Vy - (gravity)) * delta, Vx * delta))

# Logic for throwing at an extreme angle
func _overhand_behavior(delta : float) -> void :
	var firing_angle = 70.0
	var gravity = 9.8
	# Calculate distance to target
	var target_distance : float = global_transform.origin.distance_to(target_position)
	var projectile_velocity = target_distance / (sin(2 * deg_to_rad(firing_angle)) / gravity)
	
	# Extract the X  Y componenent of the velocity
	var Vx = sqrt(projectile_velocity) * cos(deg_to_rad(firing_angle))
	var Vy = sqrt(projectile_velocity) * sin(deg_to_rad(firing_angle))

	# Calculate flight time.
	var flight_duration = target_distance / Vx
	if(position.y >= 13 and !is_hovering):
		is_hovering = true
		var new_position = target_position
		new_position.y = 12.5
		global_transform.origin = new_position

		if hover_timer.is_stopped():
			hover_timer.start(projectile["hover_time"])
	elif(position.y <= 1):
		position.y = 1
		if despawn_timer.is_stopped():
			despawn_timer.start(projectile["despawn_time"])
	elif(done_hovering):
		position.y -= 9.8 * delta
	elif(!is_hovering and !done_hovering):
		translate(Vector3(0, (Vy - (gravity)) * delta, Vx * delta))

# Check for player collision
func _on_body_entered(body) -> void :
	if body.is_in_group("Player"):
		body.projectile_collided(projectile)
		queue_free()

# Despawn the projectile
func _on_despawn_timer_timeout() -> void :
	queue_free()

# Once hover finish start falling
func _on_hover_timer_timeout() -> void :
	is_hovering = false
	done_hovering = true

# Caculate parabolic arc to target position
func _caculate_sling_trajectory() -> void :
	var position : Vector3 = global_transform.origin
	var direction : Vector3 = (target_position - global_transform.origin).normalized()

	while position.z <= 0:
		var distance_to_middle : float = position.distance_to(middle_clamped_point)
		distance_to_middle = min(distance_to_middle, 0.01) # Clamp the distance to prevent division by zero
		var t : float = distance_to_middle / 0.01
		var new_height : float = lerp(position.y, middle_clamped_point.y, t)
		trajectory_points.append(position)
		position += direction * speed * time_step
		position.y = new_height

func _on_time_step_timer_timeout():
	if current_point_index < trajectory_points.size():
		var next_position : Vector3 = trajectory_points[current_point_index]
		global_transform.origin = next_position
		current_point_index += 1
		time_step_timer.start(time_step)
	else:
		time_step_timer.stop()


# Archive

#func _underhand_behavior(delta : float) -> void :
	#var gravity : float = -9.8
	## Gravity strength for underhhand
	## Apply gravity to vertical speed
	#vertical_speed += gravity * delta
	#
	## Update position
	#position.y += vertical_speed * delta
	#print(position.y)
	## Check if reached or passed the target height, then clamp
	#if position.y <= clamped_y_position:
		#position.y = clamped_y_position
		#vertical_speed = 0 # Optionally stop vertical movement
		#if not despawn_timer.is_stopped():
			#despawn_timer.start(projectile["despawn_time"])
	#else:
		#position.z += speed * delta  # Assuming forward movement is along the z-axis

#
#func _overhand_behavior(delta : float) -> void :
	#var gravity : float = -20.0 # Assuming a stronger gravity for faster descent
#
	#if not is_hovering and position.y < clamped_hover_position and position.y > clamped_y_position:
		## Initial ascent or descent phase
		#if not done_hovering:
			## Ascent phase: Reverse gravity's effect to 'push' upwards
			#vertical_speed += (-gravity * delta) # Invert gravity's direction for the ascent
		#else:
			## Descent phase: Apply gravity normally
			#vertical_speed += gravity * delta
#
		#position.y += vertical_speed * delta
		## Continue moving forward while rising or falling
		#if not done_hovering:
			#position.z += speed * delta
#
	#elif not is_hovering and position.y >= clamped_hover_position and not done_hovering:
		## Reached hover position, initiate hovering
		#is_hovering = true
		#vertical_speed = 0  # Neutralize vertical speed to simulate hovering
		#position.y = clamped_hover_position  # Clamp to hover position
		#hover_timer.start(projectile["hover_time"])  # Begin hover period
#
	#if position.y <= clamped_y_position and done_hovering:
		## After hovering, ensure it doesn't go below the clamped position
		#position.y = clamped_y_position
		#vertical_speed = 0  # Stop any vertical movement
		#if not despawn_timer.is_stopped():
			#despawn_timer.start(projectile["despawn_time"])



	#
	#if position.z > 0 and not returnTrip and projectile["type"] == Shared.E_PROJECTILE_TYPE.BOOMERANG:
		#returnTrip = true
		#target_speed = -speed
		#smooth_turn_timer = smooth_turn_duration # Reset the timer for smooth turn
	#elif returnTrip:
		#if smooth_turn_timer > 0:
			#print("turning back")
			#smooth_turn_timer -= delta # Decrement the timer
			#var t = 1 - smooth_turn_timer / smooth_turn_duration # Calculate interpolation factor
			#var current_speed = lerp(speed, target_speed, t) # Interpolate speed
			#var new_position = global_position + direction * current_speed * delta
			#new_position.y = middle_clamped_point.y
			#position = new_position
		#elif global_transform.origin.distance_to(middle_clamped_point) < .05:
			#var new_position = global_position + -direction * speed * delta
			#position = new_position
		#else:
			#var new_position = global_position + -direction * speed * delta
			#new_position.y = middle_clamped_point.y
			#position = new_position
	#else:
		#var distance_to_middle : float = global_transform.origin.distance_to(middle_clamped_point)
		#distance_to_middle = min(distance_to_middle, 0.01)
		#var t : float = distance_to_middle / 0.01
		#var new_height : float = lerp(position.y, middle_clamped_point.y, t)
		#var new_postion = global_position + direction * speed * delta
		#new_postion.y = new_height
		#position = new_postion

