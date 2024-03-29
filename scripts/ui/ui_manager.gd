extends Control
class_name UIManager

#Other
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var animation : AnimationPlayer = get_node("Title Screen UI/AnimationPlayer")

#Title Screen
@onready var title_screen : Control = get_node("Title Screen UI")
@onready var main_menu : Control = get_node("Title Screen UI/MarginContainer/VBoxContainer/Main Menu")
@onready var level_selection : Control = get_node("Title Screen UI/MarginContainer/VBoxContainer/Level Selection")
@onready var setting : Control = get_node("Title Screen UI/MarginContainer/VBoxContainer/Setting")
@onready var credits : Control = get_node("Title Screen UI/MarginContainer/VBoxContainer/Credits")
@onready var exit_button : Button = get_node("Title Screen UI/MarginContainer/VBoxContainer/Main Menu/GridContainer/Exit")

#Pause Screen UI
@onready var pause_screen : Control = get_node("Pause Screen UI")
@onready var pause_menu : Control = get_node("Pause Screen UI/MarginContainer/MarginContainer/VBoxContainer/Pause Menu")
@onready var pause_setting : Control = get_node("Pause Screen UI/MarginContainer/MarginContainer/VBoxContainer/Pause Setting")

#Game UI
@onready var game_ui : Control = get_node("Game Screen UI")
@onready var score : Label = get_node("Game Screen UI/MarginContainer/VBoxContainer/Top UI Bar/VBoxContainer/PlayerScore 3")
@onready var time : Label = get_node("Game Screen UI/MarginContainer/VBoxContainer/Top UI Bar/VBoxContainer/Time Left")
@onready var laughter_meter : ProgressBar = get_node("Game Screen UI/MarginContainer/VBoxContainer/VBoxContainer/Laughter Meter")
@onready var joke_bar : BoxContainer = get_node("Game Screen UI/MarginContainer/VBoxContainer/Joke Bar")
@onready var combo_counter : Label = get_node("Game Screen UI/ComboCounter")

@onready var curtain : Curtain = get_node("Curtain Container")
@onready var game_over : Control = get_node("Transition UI/Game Over")
@onready var black_screen : TextureRect = get_node("Transition UI/Black Screen")
@onready var transition : AnimationPlayer = get_node("Transition Animation")

# Local Variable
var cluck_status : Dictionary = {
	"neutral" : load("res://sprites/audience/CluckNeutral.png"),
	"nervous" : load("res://sprites/audience/CluckNervous.png"),
	"afraid" : load("res://sprites/audience/CluckAfraid.png"),
	"dead" : load("res://sprites/audience/CluckDead.png"),
}

var player_status : Dictionary = {
	1 : "Game Screen UI/MarginContainer/VBoxContainer/VBoxContainer/Laughter Meter/Player 1",
	2 : "Game Screen UI/MarginContainer/VBoxContainer/VBoxContainer/Laughter Meter/Player 2",
}

var player_score : Dictionary = {
	1 : "Game Screen UI/MarginContainer/VBoxContainer/VBoxContainer/Laughter Meter/PlayerScore 1",
	2 : "Game Screen UI/MarginContainer/VBoxContainer/VBoxContainer/Laughter Meter/PlayerScore 2",
	3 : "Game Screen UI/MarginContainer/VBoxContainer/Top UI Bar/VBoxContainer/PlayerScore 3",
}

func _ready() -> void :
	match OS.get_name():
		"Web": exit_button.visible = false

func _process(delta : float) -> void:
	if (game_manager.is_playing):
		_sync_score()
		_sync_laughter()
		_sync_combo_counter()
		_sync_time()

func _input(event : InputEvent) -> void :
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(game_manager.is_playing and title_screen.visible == false):
				pause_screen.visible = !pause_screen.visible
				get_tree().paused = pause_screen.visible 

func _sync_score() -> void :
	if (game_manager.is_singleplayer and game_manager.player_list.size() > 0):
		score.text = str(int(game_manager.player_list[1]["score"]))
	elif (!game_manager.is_singleplayer):
		score.visible = false
		for player_num in game_manager.player_list.keys():
			var player = game_manager.player_list[player_num]
			var score = get_node(player_score[player_num])

			score.text = str(int(player["score"]))
			score.visible = true

func _sync_laughter() -> void :
	laughter_meter.value = _round_to_dec(float(game_manager.laughter_position) / 100, 2)
	for player_num in game_manager.player_list.keys():
		var player = game_manager.player_list[player_num]
		var image = get_node(player_status[player_num])

		if (player["laughter"] <= 0):
			image.texture = cluck_status["dead"]
		elif (player["laughter"] <= 20):
			image.texture = cluck_status["afraid"]
		elif (player["laughter"] <= 40):
			image.texture = cluck_status["nervous"]
		elif (player["laughter"] <= 100):
			image.texture = cluck_status["neutral"]
			
		image.visible = true

func _sync_combo_counter() -> void :
	combo_counter.visible = game_manager.additional_multiplier > 0
	combo_counter.text = str(game_manager.additional_multiplier + 1) + "x"
	
func _sync_volume(node : Control) -> void :
	node.get_node("PanelContainer/GridContainer/Master Slider").value = audio_manager.master_volume
	node.get_node("PanelContainer/GridContainer/Background Slider").value = audio_manager.background_volume
	node.get_node("PanelContainer/GridContainer/Sound Effect Slider").value = audio_manager.sound_effect_volume

func _sync_time() -> void :
	time.text = str(int(game_manager.game_timer.time_left))

func _round_to_dec(num : float, digit : int) -> float :
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

#Main Menu
func _on_start_game_pressed() -> void :
	game_manager.is_singleplayer = true
	level_selection.visible = true
	main_menu.visible = false

func _on_how_to_play_pressed() -> void :
	pass # Replace with function body.

func _on_credits_pressed() -> void :
	credits.visible = true
	main_menu.visible = false

func _on_settings_pressed() -> void :
	main_menu.visible = false
	setting.visible = true
	_sync_volume(setting)

func _on_back_pressed() -> void :
	main_menu.visible = true
	credits.visible = false
	setting.visible = false

func _on_exit_pressed() -> void :
	get_tree().quit()

#Pause Menu
func _on_pause_resume_pressed() -> void :
	pause_screen.visible = false
	get_tree().paused = false

func _on_pause_restart_pressed() -> void :
	game_manager.restart_level()
	pause_screen.visible = false
	get_tree().paused = false 

func _on_pause_setting_pressed() -> void :
	pause_menu.visible = false
	pause_setting.visible = true
	_sync_volume(pause_setting)

func _on_pause_setting_back_pressed() -> void :
	pause_menu.visible = true
	pause_setting.visible = false

func _on_pause_exit_pressed() -> void :
	game_manager.back_to_menu()

#Setting Slider
func _on_master_slider_value_changed(value) -> void :
	AudioServer.set_bus_volume_db(audio_manager.MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.MASTER_BUS_ID, value < .05)
	audio_manager.master_volume = value

func _on_sound_effect_slider_value_changed(value) -> void :
	AudioServer.set_bus_volume_db(audio_manager.SOUND_EFFECT_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.SOUND_EFFECT_ID, value < .05)
	audio_manager.background_volume = value

func _on_background_slider_value_changed(value) -> void :
	AudioServer.set_bus_volume_db(audio_manager.BACKGROUND_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.BACKGROUND_BUS_ID, value < .05)
	audio_manager.sound_effect_volume = value

#Game UI
func _on_ui_gear_button_pressed() -> void :
	pause_screen.visible = !pause_screen.visible
	get_tree().paused = pause_screen.visible 

func _on_level_pressed(index : int, difficulty : Shared.E_DIFFICULTY_TYPE) -> void :
	get_tree().call_group("Curtains", "opening_curtain")
	title_screen.visible = false
	game_manager.load_level(index, difficulty)

func _on_level_back_pressed():
	level_selection.visible = false
	main_menu.visible = true

func _on_versus_pressed():
	game_manager.is_singleplayer = false
	level_selection.visible = true
	main_menu.visible = false

func createSplat(fade_speed : float) -> void :
	var tomato_splat_ui : TomatoSplat = get_node("Game Screen UI/TomatoSplat")
	tomato_splat_ui.createSplat(fade_speed)

func _on_try_again_pressed():
	get_tree().call_group("Curtains", "closing_curtain")
	game_manager.game_state = Shared.E_GAME_STATE.START

func try_level_again():
	get_tree().call_group("Curtains", "opening_curtain")
	game_manager.game_state = Shared.E_GAME_STATE.PLAYING
	get_tree().paused = false
	game_over.visible = false
	game_manager.restart_level()

func _on_gameover_quit_pressed():
	game_over.visible = false
	curtain.visible = true
	game_manager.back_to_menu()
	
func show_game_over():
	get_tree().paused = true
	game_over.visible = true
	get_tree().call_group("Curtains", "opening_curtain")

#func _on_transition_animation_finished(anim_name):
	#if (anim_name == "fade_to_black"):
		#game_over.visible = true
		#curtain.visible = false
		#black_screen.visible = false
