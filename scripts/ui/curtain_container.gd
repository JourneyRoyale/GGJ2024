extends Node2D

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var left : AnimatedSprite2D = get_node("Left Curtain")
@onready var right : AnimatedSprite2D = get_node("Right Curtain")

func _ready() -> void :
	left.play("closed")
	right.play("closed")

func _on_left_curtain_animation_finished() -> void :
	var anim_name = left.animation.get_basename()
	if anim_name == "closing":
		left.play("closed")
		game_manager.back_to_menu()
	if anim_name == "opening":
		left.play("open")

func _on_right_curtain_animation_finished() -> void :
	var anim_name = right.animation.get_basename()
	if anim_name == "closing":
		right.play("closed")
	if anim_name == "opening":
		right.play("open")

func start_game() -> void :
	left.play("opening")
	right.play("opening")

func end_game() -> void :
	left.play("closing")
	right.play("closing")
