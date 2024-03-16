extends CharacterBody3D
class_name Comedian

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var sprite : AnimatedSprite3D = get_node("Sprite")
@onready var invulnerable_timer : Timer = get_node("InvulnerableTimer")
@onready var stun_timer : Timer = get_node("StunTimer")
@onready var fly_timer : Timer = get_node("FlyTimer")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var ui_screen = get_node("/root/Game/Ui Screen")
@onready var collision : CollisionShape3D = get_node("CollisionShape3D")
@onready var joke : Joke = get_node("Joke")
@onready var egg : Egg = get_node("Joke/Egg")

# Export
const ACCEL = 1
const SPEED = 7
const JUMP_VELOCITY = 5.0
const INERTIA = 0.3

# Init variable from resources
var invulnerable_time = 1
var stun_time = .25
var fly_time = 1

# Local variable
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var idle = "front";
var last_move = "left";
var is_moving = false;
var is_stunned = false
var is_dead = false 
var is_invulnerable = false
var is_flying = false
var is_falling = false

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource

	invulnerable_time = level_resource.invulnerable_time
	stun_time = level_resource.stun_time

func _ready() -> void :
	if not is_dead:
		audio_manager.play_music(int(Shared.E_BACKGROUND_MUSIC.RAGTIME), Shared.E_AudioType.BACKGROUND)
		animation_player.play("default")

func _input(event : InputEvent) -> void :
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z and not is_flying:
			get_tree().call_group("AudienceManager", "check_for_match", egg, egg.timing())
			egg.reset_egg()
		if event.keycode == KEY_X:
			egg.emoji.set_random_emoji()
		if event.keycode == KEY_C and is_on_floor():
			velocity.y = JUMP_VELOCITY

func _physics_process(delta : float) -> void :
	if not is_stunned or is_dead:
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
		
		
		if is_flying:
			position.y = 4
		elif is_on_floor():
			is_falling = false
		elif is_falling:
			velocity.y -= gravity * 2 * delta
		elif position.y >= 4:
			_fly()
		
		if (velocity.x == 0 and velocity.z == 0):
			sprite.stop()
	
	move_and_slide()

# On stun timeout
func _on_stun_timer_timeout() -> void :
	if not is_dead:
		animation_player.play("Invuln")
		is_stunned = false
		stun_timer.stop()
		invulnerable_timer.start(invulnerable_time)
		sprite.play("idle_from_hit")

# On invulnerablility timeout
func _on_invulnerable_timer_timeout() -> void :
	if not is_dead:
		is_invulnerable = false
		invulnerable_timer.stop()
		animation_player.stop()
		animation_player.play("default")
		get_node("Sprite").visible = true
		show()

func _on_fly_timer_timeout():
	_falling()

func _fly():
	is_flying = true
	is_falling = false
	is_invulnerable = true
	collision.disabled = true
	joke.visible = false
	fly_timer.start(fly_time)

func _falling():
	is_flying = false
	is_falling = true
	is_invulnerable = false
	collision.disabled = false
	joke.visible = true

# Play Game Over Animation
func thats_all_folks() -> void :
	if not is_dead:
		is_dead = true
		is_invulnerable = false
		audio_manager.stop_music()
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BWACK), Shared.E_AudioType.SOUND_EFFECT)
		animation_player.stop()
		animation_player.play("yoink")
		sprite.play("yoink")

# On Tomato hit player
func projectile_collided() -> void :
	if not is_dead or is_invulnerable:
		ui_screen.createSplat()
		
		game_manager.register_hurt()
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AudioType.SOUND_EFFECT)
		sprite.play("hit")
		animation_player.play("Invuln")
		is_invulnerable = true
		is_stunned = true
		stun_timer.start()
		invulnerable_timer.start()
