extends Node2D
class_name Curtain

# On Ready
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var left : AnimatedSprite2D = get_node("Left Curtain")
@onready var right : AnimatedSprite2D = get_node("Right Curtain")
@onready var ui_manager : UIManager = get_parent()

func _ready() -> void :
	closed_curtain()

func opening_curtain() -> void :
	left.play("opening")
	right.play("opening")

func open_curtain() -> void :
	left.play("open")
	right.play("open")

func closing_curtain() -> void :
	left.play("closing")
	right.play("closing")

func closed_curtain() -> void :
	left.play("closed")
	right.play("closed")

func _on_curtain_animation_finished() -> void :
	var left_anim_name = left.animation.get_basename()
	var right_anim_name = right.animation.get_basename()
	if left_anim_name == "closing" or right_anim_name == "closing":
		left.play("closed")
		right.play("closed")

		if (game_manager.game_state == Shared.E_GAME_STATE.GAME_OVER):
			ui_manager.show_game_over()
		elif(game_manager.game_state == Shared.E_GAME_STATE.VICTORY):
			ui_manager.show_score_screen()
		elif (game_manager.game_state == Shared.E_GAME_STATE.START):
			ui_manager.try_level_again()
	if left_anim_name == "opening" or right_anim_name == "opening":
		left.play("open")
		right.play("open")
		
		if (game_manager.game_state == Shared.E_GAME_STATE.PLAYING):
			ui_manager.game_ui.visible = true
