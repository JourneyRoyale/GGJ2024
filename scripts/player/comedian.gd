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
@onready var ui_screen : UIManager = get_node("/root/Game/Ui Screen")
@onready var collision : CollisionShape3D = get_node("CollisionShape3D")
@onready var joke : Joke = get_node("Joke")
@onready var egg : Egg = get_node("Joke/Egg")
@onready var target : Node3D = get_node("Target")

# Export
@export var player_num : int = 1

# Resource Variable
var fly_time
var accel
var speed
var jump_velocity
var inertia

# Init variable
var target_map : TargetMap

# Local variable
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var idle : String = "front";
var last_move : String = "left";
var is_moving : bool = false;
var is_stunned : bool = false
var is_dead : bool = false 
var is_invulnerable : bool = false
var is_start_flying : bool = false
var is_flying : bool = false
var is_falling : bool = false
var fly_count : int = 3

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource
	
	fly_time = level_resource.fly_time
	accel = level_resource.accel
	speed = level_resource.speed
	jump_velocity = level_resource.jump_velocity
	inertia = level_resource.inertia
	
	target_map = get_tree().get_nodes_in_group("TargetMap")[0] as TargetMap

func _ready() -> void :
	_init_resources()
	game_manager.add_player(self)
	if not is_dead:
		audio_manager.play_music(int(Shared.E_BACKGROUND_MUSIC.RAGTIME), Shared.E_AUDIO_TYPE.BACKGROUND)
		animation_player.play("default")

func _input(event : InputEvent) -> void :
	if(player_num == 1):
		if event is InputEventKey and event.pressed:
			if event.is_action_pressed("p1_match") and !is_flying and egg.is_active and !egg.is_early(self):
				get_tree().call_group("AudienceManager", "check_for_match", egg, egg.timing(), self)
				egg.reset_egg()
			if event.is_action_pressed("p1_switch") :
				egg.switch_egg()
			if event.is_action_pressed("p1_fly")  and is_on_floor() and fly_count > 0:
				fly_count -= 1
				is_start_flying = true
				velocity.y = jump_velocity
				sprite.play("fly")
	elif(player_num == 2):
		if event is InputEventKey and event.pressed:
			if event.is_action_pressed("p2_match") and !is_flying and egg.is_active and !egg.is_early(self):
				get_tree().call_group("AudienceManager", "check_for_match", egg, egg.timing(), self)
				egg.reset_egg()
			if event.is_action_pressed("p2_switch") :
				egg.switch_egg()
			if event.is_action_pressed("p2_fly")  and is_on_floor() and fly_count > 0:
				fly_count -= 1
				is_start_flying = true
				velocity.y = jump_velocity
				sprite.play("fly")

func _physics_process(delta : float) -> void :
	if !is_on_floor() and (!is_start_flying and !is_flying):
		velocity.y -= gravity * 2 * delta
	
	if not is_stunned and not is_dead:
		var input_dir
		if (player_num == 2):
			input_dir = Input.get_vector("p2_move_left", "p2_move_right", "p2_move_up", "p2_move_down")
		else:
			input_dir = Input.get_vector("p1_move_left", "p1_move_right", "p1_move_up", "p1_move_down")
		
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
	
	if(target_map != null):
		position.x = clamp(position.x, target_map.target_constraint["min_x"], target_map.target_constraint["max_x"])
		position.z = clamp(position.z, target_map.target_constraint["min_z"], target_map.target_constraint["max_z"])
	
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
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BWACK), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		animation_player.play("yoink")
		sprite.play("yoink")

# On Tomato hit player
func projectile_collided(projectile : Dictionary, direction : Vector3) -> void :
	if not is_dead:
		for modification : String in projectile.keys():
			match (modification):
				"score":
					var score : int = projectile["score"]
					if (score > 0):
						print("Add Money Score")
					else:
						game_manager.register_hurt(score, self)
						audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
						sprite.play("hit")
				"stun":
					var stun_time : float = projectile["stun"]
					stun_timer.start(stun_time)
					is_stunned = true
					sprite.play("stun")
				"knockback":
					var knockback : int = projectile["knockback"]
					velocity = knockback * direction
					velocity.y = 0
				"invulnerabile":
					var invulnerabile_time : float = projectile["invulnerabile"]
					animation_player.play("Invuln")
					invulnerable_timer.start(invulnerabile_time)
					is_invulnerable = true
				"muddle":
					var muddle_type : String = projectile["muddle"]
					if (muddle_type == "tomato"):
						ui_screen.createSplat(projectile["fade_speed"])

func shot(is_dead : bool) -> void :
	if (is_dead):
		sprite.play("yoink")
		joke.visible = false
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BWACK), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		get_tree().paused = true
		game_manager.shock_timer.start()

func win() -> void :
	sprite.play("win")
	joke.visible = false
	audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BWACK), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
	get_tree().paused = true
	game_manager.shock_timer.start()
