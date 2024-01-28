extends CharacterBody3D

@export var ACCEL = 1
@export var SPEED = 7
@export var JUMP_VELOCITY = 5.0
@export var INERTIA = 0.3

@onready var sprite = get_node("Sprite")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var invulnerable_timer : Timer = get_node("InvulnerableTimer")
@onready var stun_timer : Timer = get_node("StunTimer")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var in_spotlight = false

var idle = "front"

var last_move = "left"

var invulnerable = false
var stunned = false

var invulnerable_time = 1
var stun_time = .25

func _ready():
	audio_manager.play_music('Ragtime', 'Background')

func on_spotlight_entered():
	in_spotlight = true
	audio_manager.play_music('PowerUp', 'Sound Effect')
	
func on_spotlight_exited():
	in_spotlight = false

func projectile_collided():
	if invulnerable:
		return
	game_manager.register_hit()
	audio_manager.play_music('HitHurt', 'Sound Effect')
	sprite.play("hit")
	animation_player.play("Invuln")
	invulnerable = true
	stunned = true
	stun_timer.start()
	invulnerable_timer.start()
	#TODO: Notify gamemanager

var inv_alt = 0

func _physics_process(delta):
	if stunned:
		velocity.x = 0
		velocity.z = 0
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x += direction.x * ACCEL
	velocity.z += direction.z * ACCEL
	velocity.x = clamp(velocity.x, -SPEED, SPEED)
	velocity.z = clamp(velocity.z, -SPEED, SPEED)
	velocity.x = move_toward(velocity.x, 0, INERTIA)
	velocity.z = move_toward(velocity.z, 0, INERTIA)
	if direction.x > 0:
		sprite.play("walk_right")
		last_move = "right"
	elif direction.x < 0:
		sprite.play("walk_left")
		last_move = "left"
	else:
		if last_move == "left":
			sprite.play("idle_from_left")
		elif last_move == "right":
			sprite.play("idle_from_right")
	
	if (velocity.x == 0 and velocity.z == 0):
		sprite.stop()
	else:
		sprite.play('new_animation');

	move_and_slide()

func _on_stun_timer_timeout():
	stunned = false
	invulnerable_timer.start(invulnerable_time)
	sprite.play("idle_from_hit")

func _on_invulnerable_timer_timeout():
	invulnerable = false
	animation_player.stop()
	get_node("Sprite").visible = true
	show()
