extends Control

#Scenc
var game_scene = load("res://scenes/game.tscn")

#Other
@onready var animation = get_node("TitleScreen/AnimationPlayer")
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var current_scene_name = get_tree().get_current_scene().get_name()

#Title Screen
@onready var title_screen = get_node("TitleScreen")
@onready var main_menu = get_node("TitleScreen/MarginContainer/VBoxContainer/Main Menu")
@onready var setting = get_node("TitleScreen/MarginContainer/VBoxContainer/Setting")
@onready var credits = get_node("TitleScreen/MarginContainer/VBoxContainer/Credits")

#Pause Screen
@onready var pause_screen = get_node("Pause Screen")
@onready var pause_menu = get_node("Pause Screen/MarginContainer/MarginContainer/VBoxContainer/Pause Menu")
@onready var pause_setting = get_node("Pause Screen/MarginContainer/MarginContainer/VBoxContainer/Pause Setting")

#Game UI
@onready var game_ui = get_node("GameUI")
@onready var score = get_node("GameUI/MarginContainer/VBoxContainer/Top UI Bar/PlayerScore")
@onready var laughter_meter = get_node("GameUI/MarginContainer/VBoxContainer/Top UI Bar/Laughter Meter")
@onready var joke_bar = get_node("GameUI/MarginContainer/VBoxContainer/Joke Bar")
@onready var combo_counter = get_node("GameUI/ComboCounter")

func _process(delta):
	if (game_manager.isPlaying):
		_sync_score()
		_sync_laughter()
		_sync_combo_counter()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(current_scene_name != "start" and title_screen.visible == false):
				pause_screen.visible = !pause_screen.visible
				get_tree().paused = pause_screen.visible 


func _sync_score():
	score.text = str(int(game_manager.player_score))

func _sync_laughter():
	laughter_meter.value = _round_to_dec(game_manager.laughter_score / 100, 2)

func _sync_combo_counter():
	combo_counter.visible = game_manager.additional_multiplier > 0
	combo_counter.text = str(game_manager.additional_multiplier + 1) + "x"
	

func _sync_volume(node):
	node.get_node("PanelContainer/GridContainer/Master Slider").value = audio_manager.master_volume
	node.get_node("PanelContainer/GridContainer/Background Slider").value = audio_manager.background_volume
	node.get_node("PanelContainer/GridContainer/Sound Effect Slider").value = audio_manager.sound_effect_volume 

func _round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

#Main Menu
func _on_start_game_pressed():
	get_tree().call_group("Curtains", "start_game")
	title_screen.visible = false
	game_ui.visible = true
	game_manager.isPlaying = true
	var instance = game_scene.instantiate()
	get_node("/root/Game/Game Holder").add_child(instance)

func _on_how_to_play_pressed():
	pass # Replace with function body.
	
func _on_credits_pressed():
	credits.visible = true
	main_menu.visible = false

func _on_settings_pressed():
	main_menu.visible = false
	setting.visible = true
	_sync_volume(setting)

func _on_back_pressed():
	main_menu.visible = true
	credits.visible = false
	setting.visible = false

func _on_exit_pressed():
	get_tree().quit()
	pass # Replace with function body.

#Pause Menu
func _on_pause_resume_pressed():
	pause_screen.visible = false
	get_tree().paused = pause_screen.visible 

func _on_pause_restart_pressed():
	get_node("/root/Game/Game Holder").get_child(0).queue_free()
	var instance = game_scene.instantiate()
	get_node("/root/Game/Game Holder").add_child(instance)
	pause_screen.visible = false
	get_tree().paused = pause_screen.visible 
	game_manager.reset_setting()
	pass

func _on_pause_setting_pressed():
	pause_menu.visible = false
	pause_setting.visible = true
	_sync_volume(pause_setting)

func _on_pause_setting_back_pressed():
	pause_menu.visible = true
	pause_setting.visible = false

func _on_pause_exit_pressed():
	game_manager.exit_setting()
	audio_manager.stop_music();
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")
	game_ui.visible = false

#Setting Slider
func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(audio_manager.MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.MASTER_BUS_ID, value < .05)
	audio_manager.master_volume = value

func _on_sound_effect_slider_value_changed(value):
	AudioServer.set_bus_volume_db(audio_manager.SOUND_EFFECT_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.SOUND_EFFECT_ID, value < .05)
	audio_manager.background_volume = value

func _on_background_slider_value_changed(value):
	AudioServer.set_bus_volume_db(audio_manager.BACKGROUND_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(audio_manager.BACKGROUND_BUS_ID, value < .05)
	audio_manager.sound_effect_volume = value

#Game UI
func _on_ui_gear_button_pressed():
	pause_screen.visible = !pause_screen.visible
	get_tree().paused = pause_screen.visible 

func createSplat():
	get_node("GameUI/TomatoSplat").createSplat()
