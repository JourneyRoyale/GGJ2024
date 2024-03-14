extends CharacterBody3D
class_name Heckler

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D")
@onready var throw_delay_timer : Timer = get_node("Throw Delay Timer")
@onready var walk_timer : Timer = get_node("Walk Timer")

# Constants
var LEFT_BOUNDARY : int = -7
var RIGHT_BOUNDARY :int = 7

# Init variable from resources
var move_speed : float
var aggressiveness : float
var throw_delay : float
var move_time : Dictionary

# Local variable
var packed_projectile = load("res://prefab/audience/projectile.tscn")
var is_moving = false
var current_direction = Vector3(1.0, 0, 0).normalized()  # Starts moving right
var assigned_chair : Chair
var assigned_floor
var lanes = [];
var current_lane = 0
var health = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init_resources() -> void :
	var heckler_resource : HecklerResource = game_manager.level_resource.heckler

	move_time = heckler_resource.move_time
	move_speed = heckler_resource.move_speed
	aggressiveness = heckler_resource.aggressiveness
	throw_delay = heckler_resource.throw_delay

# Play Spawn Animation When Spawned
func _ready() -> void :
	_init_resources()
	sprite.play("spawn")
	lanes = game_manager.heckler_lane_x_positions;

func _physics_process(delta : float) -> void :
	if not is_on_floor():
		velocity.y -= gravity * move_speed * delta

	if is_moving:
		position += current_direction * move_speed * delta * 5
		
		# Check boundaries
		if position.x <= LEFT_BOUNDARY and current_direction.x < 0:
			current_direction.x = -current_direction.x  # Change to moving right
		elif position.x >= RIGHT_BOUNDARY and current_direction.x > 0:
			current_direction.x = -current_direction.x  # Change to moving left
			
		for lane_index in range(lanes.size()):
			if abs(position.x - lanes[lane_index]) < 0.02 and not game_manager.filled_lane_x_positions[lane_index]:
				game_manager.filled_lane_x_positions[lane_index] = true
				current_lane = lane_index
				_stop_moving()
				break
	
	move_and_slide()

# Start Heckler Movement
func _start_moving():
	is_moving = true
	animation_player.play("bounce")
	sprite.play("default")
	walk_timer.start(game_manager.rng.randi_range(move_time["min"], move_time["max"]))

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
	
	throw_delay_timer.start(throw_delay)

# Move after throwing finished
func _on_throw_timer_timeout() -> void :
	var instance = packed_projectile.instantiate()
	# Add the projectile as a sibling rather than a child
	if get_parent():
		get_parent().add_child(instance)
		instance.global_transform = global_transform 
	
	_start_moving()

func _on_walk_timer_timeout() -> void :
	_stop_moving()

# On Animation Finished
func _on_animated_sprite_3d_animation_finished() -> void :
	var anim_name = sprite.animation.get_basename()
	
	#Spawn animation finish, start moving
	if(anim_name == "spawn"):
		sprite.play("default")
		_start_moving()
	
	#On animation death finished, destory heckler
	if(anim_name == "death"):
		get_tree().call_group("AudienceManager", "kill_heckler", self)

# Play Death Animation
func play_death() -> void :
	sprite.play("death")
