extends Control
class_name UIManager

#Other
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var animation : AnimationPlayer = get_node("TitleScreen/AnimationPlayer")

#Title Screen
@onready var title_screen : Control = get_node("TitleScreen")
@onready var main_menu : Control = get_node("TitleScreen/MarginContainer/VBoxContainer/Main Menu")
@onready var level_selection : Control = get_node("TitleScreen/MarginContainer/VBoxContainer/Level Selection")
@onready var setting : Control = get_node("TitleScreen/MarginContainer/VBoxContainer/Setting")
@onready var credits : Control = get_node("TitleScreen/MarginContainer/VBoxContainer/Credits")
@onready var exit_button : Button = get_node("TitleScreen/MarginContainer/VBoxContainer/Main Menu/GridContainer/Exit")

#Pause Screen
@onready var pause_screen : Control = get_node("Pause Screen")
@onready var pause_menu : Control = get_node("Pause Screen/MarginContainer/MarginContainer/VBoxContainer/Pause Menu")
@onready var pause_setting : Control = get_node("Pause Screen/MarginContainer/MarginContainer/VBoxContainer/Pause Setting")

#Game UI
@onready var game_ui : Control = get_node("GameUI")
@onready var score : Label = get_node("GameUI/MarginContainer/VBoxContainer/Top UI Bar/PlayerScore")
@onready var laughter_meter : ProgressBar = get_node("GameUI/MarginContainer/VBoxContainer/Top UI Bar/Laughter Meter")
@onready var joke_bar : BoxContainer = get_node("GameUI/MarginContainer/VBoxContainer/Joke Bar")
@onready var combo_counter : Label = get_node("GameUI/ComboCounter")

func _ready() -> void :
	match OS.get_name():
		"Web": exit_button.visible = false

func _process(delta : float) -> void:
	if (game_manager.is_playing):
		_sync_score()
		_sync_laughter()
		_sync_combo_counter()

func _input(event : InputEvent) -> void :
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(game_manager.is_playing and title_screen.visible == false):
				pause_screen.visible = !pause_screen.visible
				get_tree().paused = pause_screen.visible 

func _sync_score() -> void :
	score.text = str(int(game_manager.player_score))

func _sync_laughter() -> void :
	laughter_meter.value = _round_to_dec(game_manager.laughter_score / 100, 2)

func _sync_combo_counter() -> void :
	combo_counter.visible = game_manager.additional_multiplier > 0
	combo_counter.text = str(game_manager.additional_multiplier + 1) + "x"
	
func _sync_volume(node : Control) -> void :
	node.get_node("PanelContainer/GridContainer/Master Slider").value = audio_manager.master_volume
	node.get_node("PanelContainer/GridContainer/Background Slider").value = audio_manager.background_volume
	node.get_node("PanelContainer/GridContainer/Sound Effect Slider").value = audio_manager.sound_effect_volume 

func _round_to_dec(num : float, digit : int) -> float :
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

#Main Menu
func _on_start_game_pressed() -> void :
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

func createSplat() -> void :
	get_node("GameUI/TomatoSplat").createSplat()

func _on_level_pressed(index : int) -> void :
	get_tree().call_group("Curtains", "start_game")
	title_screen.visible = false
	game_ui.visible = true
	game_manager.load_level(index)

func _on_level_back_pressed():
	level_selection.visible = false
	main_menu.visible = true
