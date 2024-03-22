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
@onready var target : Node3D = get_node("Target")

# Init variable from resources
var fly_time
var accel
var speed
var jump_velocity
var inertia

# Local variable
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var idle = "front";
var last_move = "left";
var is_moving = false;
var is_stunned = false
var is_dead = false 
var is_invulnerable = false
var is_start_flying = false
var is_flying = false
var is_falling = false

func _init_resources() -> void :
	var comedian_resource : ComedianResource = game_manager.level_resource.comedian
	
	fly_time = comedian_resource.fly_time
	accel = comedian_resource.accel
	speed = comedian_resource.speed
	jump_velocity = comedian_resource.jump_velocity
	inertia = comedian_resource.inertia

func _ready() -> void :
	_init_resources()
	game_manager.add_player(self)
	if not is_dead:
		audio_manager.play_music(int(Shared.E_BACKGROUND_MUSIC.RAGTIME), Shared.E_AudioType.BACKGROUND)
		animation_player.play("default")

func _input(event : InputEvent) -> void :
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E and !is_flying and egg.is_active and !egg.is_early():
			get_tree().call_group("AudienceManager", "check_for_match", egg, egg.timing())
			egg.reset_egg()
		if event.keycode == KEY_F:
			egg.switch_egg()
		if event.keycode == KEY_Q and is_on_floor():
			is_start_flying = true
			velocity.y = jump_velocity
			sprite.play("fly")

func _physics_process(delta : float) -> void :
	if !is_on_floor() and (!is_start_flying and !is_flying):
		velocity.y -= gravity * 2 * delta
	
	if not is_stunned and not is_dead:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		velocity.x += direction.x * accel
		velocity.z += direction.z * accel
		velocity.x = clamp(velocity.x, -speed, speed)
		velocity.z = clamp(velocity.z, -speed, speed)
		velocity.x = move_toward(velocity.x, 0, inertia)
		velocity.z = move_toward(velocity.z, 0, inertia)
		
		if (velocity.y != jump_velocity):
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
		
		if (velocity.x == 0 and velocity.z == 0 and velocity.y != jump_velocity):
			sprite.stop()
	
	move_and_slide()

# On stun timeout
func _on_stun_timer_timeout() -> void :
	if not is_dead:
		is_stunned = false
		sprite.play("idle_from_hit")

# On invulnerablility timeout
func _on_invulnerable_timer_timeout() -> void :
	if not is_dead:
		is_invulnerable = false
		animation_player.play("default")
		get_node("Sprite").visible = true

func _on_fly_timer_timeout():
	_falling()

func _fly():
	is_flying = true
	is_falling = false
	is_invulnerable = true
	collision.disabled = true
	joke.visible = false
	fly_timer.start(2)

func _falling():
	sprite.play("idle_from_hit")
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
		animation_player.play("yoink")
		sprite.play("yoink")

# On Tomato hit player
func projectile_collided(projectile : Dictionary) -> void :
	if not is_dead:
		for modification : String in projectile.keys():
			match (modification):
				"score":
					var score : int = projectile["score"]
					if (score > 0):
						print("Add Money Score")
					else:
						game_manager.register_hurt(score)
						audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AudioType.SOUND_EFFECT)
						sprite.play("hit")
				"stun":
					var stun_time : float = projectile["stun"]
					stun_timer.start(stun_time)
					is_stunned = true
					sprite.play("stun")
				"knockback":
					var knockback : int = projectile["knockback"]
					position.z += knockback
				"invulnerabile":
					var invulnerabile_time : float = projectile["invulnerabile"]
					animation_player.play("Invuln")
					invulnerable_timer.start(invulnerabile_time)
					is_invulnerable = true
				"muddle":
					var muddle_type : String = projectile["muddle"]
					if (muddle_type == "tomato"):
						ui_screen.createSplat()

func shot() -> void :
	sprite.play("yoink")
	egg.visible = false
	audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BWACK), Shared.E_AudioType.SOUND_EFFECT)
	get_tree().paused = true
	game_manager.shock_timer.start()
	
