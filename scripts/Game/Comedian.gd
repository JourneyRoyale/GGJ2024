extends CharacterBody3D

# On Ready
@onready var sprite = get_node("Sprite")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var invulnerable_timer : Timer = get_node("InvulnerableTimer")
@onready var stun_timer : Timer = get_node("StunTimer")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var ui_screen = get_node("/root/Game/Ui Screen")

# Export
@export var ACCEL = 1
@export var SPEED = 7
@export var JUMP_VELOCITY = 5.0
@export var INERTIA = 0.3

# Constant
var invulnerable_time = 1
var stun_time = .25
var clamped_y_position = 1.945
var clamped_z_position = -0.529

# Variable
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var in_spotlight = false
var idle = "front";
var last_move = "left";
var is_moving = false;
var invulnerable = false
var stunned = false
var dead = false 
var lanes = [];
var current_lane_index = 2;


func _ready():
	lanes = game_manager.lane_x_positions;
	if !dead:
		audio_manager.play_music('Ragtime', 'Background')
		sprite.play("idle_from_left")
		animation_player.play("default")

func _physics_process(delta):
	if stunned or dead:
		return
	
	#movement in lanes
	if Input.is_action_just_pressed("move_left"):
		current_lane_index = max(current_lane_index - 1, 0) 
		sprite.play("walk_left")
		is_moving = true;

	if Input.is_action_just_pressed("move_right"):
		current_lane_index = min(current_lane_index + 1, lanes.size() - 1)
		sprite.play("walk_right")
		is_moving = true;
		
	var target_position = Vector3(lanes[current_lane_index], clamped_y_position, clamped_z_position)
	transform.origin = transform.origin.lerp(target_position, 0.1)
	
	if transform.origin.distance_to(target_position) < 0.1: # Threshold can be adjusted
		if is_moving: # Check if we were moving to stop the sprite animation
			if last_move == "left":
				sprite.play("idle_from_left")
			elif last_move == "right":
				sprite.play("idle_from_right")
			is_moving = false;

# On stun timeout
func _on_stun_timer_timeout():
	if !dead:
		animation_player.play("Invuln")
		stunned = false
		stun_timer.stop()
		invulnerable_timer.start(invulnerable_time)
		sprite.play("idle_from_hit")

# On invulnerablility timeout
func _on_invulnerable_timer_timeout():
	if !dead:
		invulnerable = false
		invulnerable_timer.stop()
		animation_player.stop()
		animation_player.play("default")
		get_node("Sprite").visible = true
		show()

# Play Game Over Animation
func thats_all_folks():
	if !dead:
		dead = true
		audio_manager.stop_music()
		audio_manager.play_music('Bwack', 'Sound Effect')
		invulnerable = false
		animation_player.stop()
		animation_player.play("yoink")
		sprite.play("yoink")

# On Tomato hit player
func projectile_collided():
	if dead or invulnerable:
		return
	  
	if ui_screen:
		ui_screen.createSplat()
	else:
		print("No UI Screen Node Found")
	
	game_manager.register_hit()
	audio_manager.play_music('HitHurt', 'Sound Effect')
	sprite.play("hit")
	animation_player.play("Invuln")
	invulnerable = true
	stunned = true
	stun_timer.start()
	invulnerable_timer.start()

# Not Used Anymore
#func on_spotlight_entered():
	#if !dead:
		#in_spotlight = true
		#audio_manager.play_music('PowerUp', 'Sound Effect')
	#
#func on_spotlight_exited():
	#if !dead:
		#in_spotlight = false
