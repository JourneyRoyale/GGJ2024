extends CharacterBody3D
class_name Heckler

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D")
@onready var throw_delay_timer : Timer = get_node("Throw Delay Timer")
@onready var walk_timer : Timer = get_node("Walk Timer")

# Init variable from resources
var move_speed : float
var aggressiveness : float
var throw_delay : float
var move_time : Dictionary

# Local variable
var packed_projectile : PackedScene = load("res://prefab/audience/projectile.tscn")
var is_moving : bool = false
var current_direction : Vector3 = Vector3(0, 0, 0).normalized()  # Starts moving right
var assigned_chair : Chair
var assigned_floor : Node3D
var health : int = 2
var boundary : Dictionary
var current_projectile : Dictionary
var last_movement : String
var target_map : TargetMap

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

func _physics_process(delta : float) -> void :
	if not is_on_floor():
		velocity.y -= gravity * move_speed * delta

	if is_moving:
		position += current_direction * move_speed * delta * 5
		
		# Check boundaries
		if position.x <= boundary["left"] and current_direction.x < 0:
			current_direction.x = -current_direction.x  # Change to moving right
			sprite.play("walk_right")
		elif position.x >= boundary["right"] and current_direction.x > 0:
			current_direction.x = -current_direction.x  # Change to moving left
			sprite.play("walk_left")
	
	move_and_slide()

# Start Heckler Movement
func _start_moving():
	is_moving = true
	_set_random_direction()
	animation_player.play("bounce")
	walk_timer.start(game_manager.rng.randi_range(move_time["min"], move_time["max"]))

func _spawn_target() -> void :
	get_viewport().get_camera_3d().spawn_target(current_projectile,self)
	pass

# Throw Tomato
func _throw_projectile() -> void :
	is_moving = false
	animation_player.play("throw")
	sprite.play("throw")
	
	throw_delay_timer.start(throw_delay)

# Move after throwing finished
func _on_throw_timer_timeout() -> void :
	var instance = packed_projectile.instantiate()
	instance.projectile = current_projectile
	
	# Configure other properties of the instance as needed
	# Add the projectile to the scene
	if get_parent():
		get_parent().add_child(instance)
		instance.global_transform = global_transform
	
	_start_moving()

func _on_walk_timer_timeout() -> void :
	animation_player.stop()
	is_moving = false
	
	if(current_projectile["type"] == Shared.E_ProjectileType.GUN):
		sprite.play("aim")
		_spawn_target()
	else:
		_throw_projectile()

# On Animation Finished
func _on_animated_sprite_3d_animation_finished() -> void :
	var anim_name = sprite.animation.get_basename()
	
	#Spawn animation finish, start moving
	if(anim_name == "spawn"):
		_start_moving()
	
	#On animation death finished, destory heckler
	if(anim_name == "death"):
		get_tree().call_group("AudienceManager", "kill_heckler", self)

func _set_random_direction() -> void :
	if randi() % 2 == 0:
		current_direction.x = 1.0  # Move right
		sprite.play("walk_right")
	else:
		current_direction.x = -1.0  # Move left
		sprite.play("walk_left")

func set_move_boundary() -> void :
	var chair_group : Node3D = assigned_chair.get_parent()
	boundary = {"left" : chair_group.get_node("Left").global_transform.origin.x, "right" : chair_group.get_node("Right").global_transform.origin.x}

# Play Death Animation
func play_death() -> void :
	sprite.play("death")

func fire_gun() -> void :
	_start_moving()
