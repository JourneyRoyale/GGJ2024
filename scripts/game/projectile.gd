extends Area3D
class_name Projectile

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var despawn_timer : Timer = get_node("Despawn Timer")
@onready var hover_timer : Timer = get_node("Hover Timer")
@onready var time_step_timer : Timer = get_node("Time Step Timer")
@onready var pre_trajectory_factory : PackedScene = preload("res://prefab/game/trajectory.tscn")

# Resource Variable
var projectile : Dictionary
var speed : int

# Init Variable
var throw_type : Shared.E_THROW_TYPE
var reterive_position : Vector3
var middle_clamped_point : Vector3
var direction : Vector3

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

# Shared Variable
var initial_position : Vector3
var target_position : Vector3

# Underhand and overhand variable
var initial_velocity : Vector3
var trajectory_point : Dictionary
var start_flight_time : float
var total_flight_time : float
var total_time_step : int = 100
var trajectory_spawn : int = 7
var trajectory_factory : Node3D

func init_variable( projectile : Dictionary, throw_type : Shared.E_THROW_TYPE, target_position : Vector3, reterive_position : Vector3) :
	self.projectile = projectile
	self.throw_type = throw_type
	self.target_position = target_position
	self.reterive_position = reterive_position
	speed = projectile["speed"]
	target_speed = projectile["speed"]

func _ready():
	initial_position = global_transform.origin
	_set_mesh_projectile()
	_set_clamped_height_point()
	_set_direction_to_target()
	
	if throw_type == Shared.E_THROW_TYPE.SLING:
		pass
	if throw_type == Shared.E_THROW_TYPE.UNDERHAND:
		_set_velocity_and_time(initial_position, target_position)
		_calculate_future_trajectory(total_time_step)
		_spawn_trajectory_point()
	if throw_type == Shared.E_THROW_TYPE.OVERHAND:
		pass

func _process(delta : float) -> void :
	if throw_type == Shared.E_THROW_TYPE.SLING:
		_sling_behavior(delta)
	if throw_type == Shared.E_THROW_TYPE.UNDERHAND:
		_underhand_behavior(delta)
	if throw_type == Shared.E_THROW_TYPE.OVERHAND:
		_overhand_behavior(delta)

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

# Logic for throwing at a moderate angle
func _underhand_behavior(delta : float) -> void :
	start_flight_time += delta
	
	if start_flight_time >= total_flight_time:
		global_transform.origin = target_position
		return
	else:
		global_transform.origin = _get_adjusted_trajectory(start_flight_time)

# Logic for throwing at an extreme angle
func _overhand_behavior(delta : float) -> void :
	var firing_angle = 70.0
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
		position.y -= gravity * delta
	elif(!is_hovering and !done_hovering):
		translate(Vector3(0, (Vy - (gravity)) * delta, Vx * delta))

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
			get_node("Brick").visible = true
		Shared.E_PROJECTILE_TYPE.MONEY:
			get_node("Money").visible = true

func _set_velocity_and_time(initial_pos, target_pos):
	# Direction toward target position
	var direction = (target_pos - initial_pos).normalized()
	# Distance to target position
	var distance = (target_pos - initial_pos).length()
	# Time to reach target
	var flight_time = sqrt(2 * distance / gravity)
	var velocity_magnitude = distance / flight_time
	
	# Calculate horizontal and vertical components of velocity
	var firing_angle_radians = deg_to_rad(45)
	var horizontal_velocity = direction * velocity_magnitude
	var vertical_velocity = velocity_magnitude * sin(firing_angle_radians)

	# Combine horizontal and vertical components into a vector
	initial_velocity = Vector3(horizontal_velocity.x, vertical_velocity, horizontal_velocity.z)
	start_flight_time = 0.0
	total_flight_time = flight_time

func _calculate_position(initial_pos, initial_velocity, time):
	# Calculate horizontal distance traveled
	var horizontal_distance = initial_velocity.x * time
	# Calculate vertical distance traveled (accounting for gravity)
	var vertical_distance = initial_velocity.y * time - 0.5 * gravity * time ** 2
	# Calculate lateral distance traveled (assuming no change in the z-axis)
	var lateral_distance = initial_velocity.z * time
	# Calculate current position
	var current_position = Vector3(
		initial_pos.x + horizontal_distance, 
		initial_pos.y + vertical_distance, 
		initial_pos.z + lateral_distance
	)
	return current_position

func _calculate_future_trajectory(total_time_step : int):
	var trajectory_point_array : Array[Vector3] = []
	var trajectory_time_array : Array[float] = []
	var time_step : float = total_flight_time / total_time_step
	
	for index in total_time_step:
		trajectory_time_array.append(time_step * index)
		trajectory_point_array.append(_calculate_position(initial_position, initial_velocity, time_step * index))
	
	# Find drop off point
	var drop_off_index = 0
	for index in trajectory_point_array.size():
		if trajectory_point_array[index].y > trajectory_point_array[index + 1].y:
			drop_off_index = index
			break
	
	# Find distance step between dropoff and target point
	var initial_drop_off_y = trajectory_point_array[drop_off_index].y
	var distance_step = (trajectory_point_array[drop_off_index].y - target_position.y) / (trajectory_point_array.size() - drop_off_index)

	# Adjust trajectory position to match target position y after drop off
	for index in trajectory_point_array.size():
		var currentIndex = drop_off_index + index
		if currentIndex < trajectory_point_array.size():
			trajectory_point_array[currentIndex].y = initial_drop_off_y - (distance_step * index)
		else:
			break
	
	for x in trajectory_time_array.size():
		var point = trajectory_point_array[x]
		var time = trajectory_time_array[x]
		trajectory_point[time] = point
	#trajectory_point = trajectory_array

func _get_adjusted_trajectory(current_flight_time : float):
	var closest_float = 0.0
	var min_difference = 999

	for flight_time in trajectory_point.keys():
		var difference = abs(current_flight_time - flight_time)
		if difference < min_difference:
			min_difference = difference
			closest_float = flight_time

	return trajectory_point[closest_float]

func _spawn_trajectory_point():
	if trajectory_factory == null:
		trajectory_factory = pre_trajectory_factory.instantiate()
	
	var append_node = get_parent().get_parent()
	var step_size = (trajectory_point.size() - 1) / trajectory_spawn
	
	for x in trajectory_spawn:
		var new_trajectory : Trajectory = trajectory_factory.duplicate()
		new_trajectory.origin_projectile = self
		append_node.add_child(new_trajectory)
		new_trajectory.global_transform.origin = trajectory_point[trajectory_point.keys()[x * step_size]]
	
	var new_trajectory : Trajectory = trajectory_factory.duplicate()
	new_trajectory.origin_projectile = self
	append_node.add_child(new_trajectory)
	new_trajectory.global_transform.origin = target_position

# Check for player collision
func _on_body_entered(body : Node) -> void :
	print(body)
	if body.is_in_group("Player"):
		var hit_direction : Vector3 = body.global_transform.origin - global_transform.origin
		var final_direction = direction.normalized() + hit_direction.normalized()
		body.projectile_collided(projectile , direction)
		queue_free()
	if body.is_in_group("Trajectory"):
		print("hit")
		if body.origin_projectile == self:
			body.queue_free()


# Despawn the projectile
func _on_despawn_timer_timeout() -> void :
	queue_free()

# Once hover finish start falling
func _on_hover_timer_timeout() -> void :
	is_hovering = false
	done_hovering = true

## Caculate parabolic arc to target position
#func _caculate_sling_trajectory() -> void :
	#var position : Vector3 = global_transform.origin
	#var direction : Vector3 = (target_position - global_transform.origin).normalized()
#
	#while position.z <= 0:
		#var distance_to_middle : float = position.distance_to(middle_clamped_point)
		#distance_to_middle = min(distance_to_middle, 0.01) # Clamp the distance to prevent division by zero
		#var t : float = distance_to_middle / 0.01
		#var new_height : float = lerp(position.y, middle_clamped_point.y, t)
		#trajectory_points.append(position)
		#position += direction * speed * time_step
		#position.y = new_height
#
#func _on_time_step_timer_timeout():
	#if current_point_index < trajectory_points.size():
		#var next_position : Vector3 = trajectory_points[current_point_index]
		#global_transform.origin = next_position
		#current_point_index += 1
		#time_step_timer.start(time_step)
	#else:
		#time_step_timer.stop()
