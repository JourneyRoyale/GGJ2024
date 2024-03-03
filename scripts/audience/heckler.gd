extends CharacterBody3D

# On Ready
@onready var animation_player = get_node("AnimationPlayer")
@onready var sprite = get_node("AnimatedSprite3D")
@onready var audio_manager = get_node("/root/AudioManager")

# Constants
var MOVE_SPEED = 1.0
var MOVE_TIME_MIN = 2.0
var MOVE_TIME_MAX = 5.0
var AGGRESSIVENESS = 0.5 # TO-DO - implement aggressiveness variable that causes heckler to stop early in front of player
var LEFT_BOUNDARY = -7
var RIGHT_BOUNDARY = 7
var THROW_DELAY = 0.6 #how long the heckler pauses to throw a tomato in seconds

# Variables
var audience_reference
var move_time = 0.0
var move_timer = 0.0
var is_moving = false
var current_direction = Vector3(1.0, 0, 0).normalized()  # Starts moving right
var packed_projectile = load("res://prefab/audience/projectile.tscn")
var assigned_floor

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


# Play Spawn Animation When Spawned
func _ready():
	sprite.play("spawn")

func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * 100 * delta

	if is_moving:
		position += current_direction * MOVE_SPEED * delta * 5
		move_timer += delta
		
		if move_timer > move_time:
			_stop_moving()
		
		# Check boundaries
		if position.x <= LEFT_BOUNDARY and current_direction.x < 0:
			current_direction.x = -current_direction.x  # Change to moving right
		elif position.x >= RIGHT_BOUNDARY and current_direction.x > 0:
			current_direction.x = -current_direction.x  # Change to moving left
	move_and_slide()

# Start Heckler Movement
func _start_moving():
	is_moving = true
	animation_player.play("bounce")
	sprite.play("default")
	move_time = randf_range(MOVE_TIME_MIN, MOVE_TIME_MAX)
	move_timer = 0.0

# Stop Heckler Movement To Throw Tomato
func _stop_moving():
	animation_player.stop()
	is_moving = false
	_throw_tomato()

# Throw Tomato
func _throw_tomato():
	is_moving = false
	animation_player.play("throw")
	sprite.play("throw")
	
	if randi() % 2 == 0:
		current_direction.x = 1.0  # Move right
	else:
		current_direction.x = -1.0  # Move left
	
	_create_throw_timer()

# Wait to throw tomato
func _create_throw_timer():
	var timer = Timer.new()  
	timer.wait_time = THROW_DELAY  # Set the wait time (1.5 seconds)
	timer.one_shot = true  # Make sure it only ticks once
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.name = "ThrowTimer"  # Naming the timer for easier identification
	add_child(timer)  # Add the timer to the node tree
	timer.start()

# Move after throwing finished
func _on_timer_timeout():
	var instance = packed_projectile.instantiate()
	# Add the projectile as a sibling rather than a child
	if get_parent():
		get_parent().add_child(instance)
		instance.global_transform = global_transform 
	
	_start_moving()
	
	# Remove throw timer 
	var timer_node = get_node("ThrowTimer")
	if timer_node:
		timer_node.queue_free()  # Safely remove the timer node

# On Animation Finished
func _on_animated_sprite_3d_animation_finished():
	var anim_name = sprite.animation.get_basename()
	
	#Spawn animation finish, start moving
	if(anim_name == "spawn"):
		sprite.play("default")
		randomize()
		_start_moving()
	
	#On Animation death finished, destory node
	if(anim_name == "death"):
		queue_free()

# Play Death Animation
func play_death():
	sprite.play("death")
