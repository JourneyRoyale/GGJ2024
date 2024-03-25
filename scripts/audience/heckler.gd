extends CharacterBody3D
class_name Heckler

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D")
@onready var throw_delay_timer : Timer = get_node("Throw Delay Timer")
@onready var walk_timer : Timer = get_node("Walk Timer")
@onready var spawn_point : Node3D = get_node("Spawn Point")
@onready var retrieve_point : Node3D = get_node("Retrieve Point")

# Init Variable
var modification : Dictionary
var current_projectile : Dictionary
var throw_type : Shared.E_THROW_TYPE
var target_map : TargetMap
var projectile_hold : Node

# Modification
var move_speed : float
var aggressiveness : float
var throw_delay : float
var move_time : Dictionary

# Local variable
var packed_projectile : PackedScene = load("res://prefab/game/projectile.tscn")
var is_moving : bool = false
var current_direction : Vector3 = Vector3(0, 0, 0).normalized()  # Starts moving right
var assigned_chair : Chair
var health : int = 2
var boundary : Dictionary
var last_movement : String

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func init_variable(modification : Dictionary, current_projectile : Dictionary, throw_type : Shared.E_THROW_TYPE, target_map : TargetMap, projectile_hold : Node) -> void :
	self.modification = modification
	self.current_projectile = current_projectile
	self.throw_type = throw_type
	self.target_map = target_map
	self.projectile_hold = projectile_hold
	
	move_speed = modification["heckler"]["move_speed"]
	aggressiveness = modification["heckler"]["aggressiveness"]
	throw_delay = modification["heckler"]["throw_delay"]
	move_time = modification["heckler"]["move_time"]

# Play Spawn Animation When Spawned
func _ready() -> void :
	sprite.sprite_frames = modification["heckler"]["sprite_frame"]
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

func _throw_protectile() -> void :
	var target_position = target_map.get_random_target_position(throw_type,aggressiveness)

	var instance : Projectile = packed_projectile.instantiate()
	instance.init_variable(current_projectile, throw_type, target_position, retrieve_point.global_transform.origin)
	
	instance.global_transform.origin = spawn_point.global_transform.origin
	projectile_hold.add_child(instance)
	
	_start_moving()

func _on_walk_timer_timeout() -> void :
	animation_player.stop()
	is_moving = false
	
	if(current_projectile["type"] == Shared.E_PROJECTILE_TYPE.GUN):
		sprite.play("aim")
		_spawn_target()
	else:
		is_moving = false
		animation_player.play("throw")
		sprite.play("throw")

# On Animation Finished
func _on_animated_sprite_3d_animation_finished() -> void :
	var anim_name = sprite.animation.get_basename()
	
	#Spawn animation finish, start moving
	if(anim_name == "spawn"):
		_start_moving()
	
	#On animation death finished, destory heckler
	if(anim_name == "death"):
		get_tree().call_group("AudienceManager", "kill_heckler", self)
	
	if(anim_name == "throw"):
		_throw_protectile()

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
