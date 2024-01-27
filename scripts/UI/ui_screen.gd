extends Control

#Other
@export var animation : NodePath

#Title Screen
@export var title_screen : Node
@export var main_menu : Node
@export var setting : Node

#Pause Screen
@export var pause_screen : Node
@export var pause_menu : Node
@export var pause_setting : Node

#Game UI
@export var timer : Node
@export var laughter_meter : Node
@export var joke_bar: Node
var packed_joke_button = load("res://scenes/JokeButton.tscn")

@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var current_scene_name = get_tree().get_current_scene().get_name()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "curtains_open":
		game_manager.playing = true
		

func _ready():
	_add_joke()

func _process(delta):
	if(game_manager.playing):
		_sync_laughter()
		_sync_time()
		
func _add_joke():
	await get_tree().create_timer(1).timeout
	var instance = packed_joke_button.instantiate()
	if(joke_bar):
		if (joke_bar.get_child_count() == game_manager.max_emoji):
			print(joke_bar.get_child_count())
			game_manager.delete_emoji(game_manager.emoji_list[0])
		
		joke_bar.add_child(instance)
		var child_ref = joke_bar.get_child(joke_bar.get_child_count() - 1)
		print('test')

		game_manager.create_emoji(child_ref)
		_add_joke()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(current_scene_name == "DemoScene"):
				pause_screen.visible = !pause_screen.visible

func _sync_volume(node):
	node.get_node("GridContainer/Master Slider").value = audio_manager.master_volume
	node.get_node("GridContainer/Background Slider").value = audio_manager.background_volume
	node.get_node("GridContainer/Sound Effect Slider").value = audio_manager.sound_effect_volume 

func _sync_laughter():
	laughter_meter.value = round_to_dec(game_manager.laughter, 2)

func _sync_time():
	timer.text = time_convert(game_manager.set_time - game_manager.timer)
	
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func time_convert(time_in_sec):
	time_in_sec = int(time_in_sec)
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	return "%02d:%02d" % [minutes, seconds]

#Main Menu
func _on_start_game_pressed():
	var animation_player = get_node(animation)
	if animation_player != null:
		animation_player.play("curtains_open")
	title_screen.visible = false

func _on_how_to_play_pressed():
	pass # Replace with function body.

func _on_settings_pressed():
	main_menu.visible = false
	setting.visible = true
	_sync_volume(setting)

func _on_back_pressed():
	main_menu.visible = true
	setting.visible = false

func _on_exit_pressed():
	get_tree().quit()
	pass # Replace with function body.

#Pause Menu
func _on_pause_resume_pressed():
	pause_screen.visible = false

func _on_pause_restart_pressed():
	pass

func _on_pause_setting_pressed():
	pause_menu.visible = false
	pause_setting.visible = true
	_sync_volume(pause_setting)

func _on_pause_setting_back_pressed():
	pause_menu.visible = true
	pause_setting.visible = false

func _on_pause_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/DemoScene.tscn")

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
