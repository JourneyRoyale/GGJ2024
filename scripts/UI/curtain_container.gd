extends Node2D

# On Ready
@onready var left : AnimatedSprite2D = get_node("LeftCurtain")
@onready var right : AnimatedSprite2D = get_node("RightCurtain")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")

func _ready():
	left.play("closed")
	right.play("closed")

func _on_left_curtain_animation_finished():
	var anim_name = left.animation.get_basename()
	if anim_name == "closing":
		left.play("closed")
		game_manager.reset_game()
	if anim_name == "opening":
		left.play("open")

func _on_right_curtain_animation_finished():
	var anim_name = right.animation.get_basename()
	if anim_name == "closing":
		right.play("closed")
	if anim_name == "opening":
		right.play("open")

func start_game():
	left.play("opening")
	right.play("opening")

func end_game():
	left.play("closing")
	right.play("closing")
