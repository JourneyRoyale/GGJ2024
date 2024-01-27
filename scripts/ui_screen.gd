extends Control

@export var main_menu : NodePath
@export var setting : NodePath
@export var pause_menu : NodePath
@export var pause_setting : NodePath
@export var animation : NodePath
@export var title_screen : NodePath
@export var pause_screen : NodePath
@export var start_game_button : NodePath

@onready var audio_manager = get_node("/root/AudioManager")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "curtains_open":
		self.hide()
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			var current_scene_name = get_tree().get_current_scene().get_name()
			print(current_scene_name)
			if(current_scene_name == "DemoScene"):
				get_node(pause_screen).visible = !get_node(pause_screen).visible
				
func _sync_volume(node):
	node.get_node("GridContainer/Master Slider").value = audio_manager.master_volume
	node.get_node("GridContainer/Background Slider").value = audio_manager.background_volume
	node.get_node("GridContainer/Sound Effect Slider").value = audio_manager.sound_effect_volume 

#Main Menu
func _on_start_game_pressed():
	var animation_player = get_node(animation)
	if animation_player != null:
		animation_player.play("curtains_open")
	get_node(main_menu).visible = false

func _on_how_to_play_pressed():
	pass # Replace with function body.
	
func _on_settings_pressed():
	get_node(main_menu).visible = false
	get_node(setting).visible = true
	_sync_volume(get_node(setting))
	
func _on_back_pressed():
	get_node(main_menu).visible = true
	get_node(setting).visible = false

func _on_exit_pressed():
	get_tree().quit()
	pass # Replace with function body.

#Pause Menu
func _on_pause_resume_pressed():
	get_node(pause_screen).visible = false

func _on_pause_restart_pressed():
	pass

func _on_pause_setting_pressed():
	get_node(pause_menu).visible = false
	get_node(pause_setting).visible = true
	_sync_volume(get_node(pause_setting))
	
	
func _on_pause_setting_back_pressed():
	get_node(pause_menu).visible = true
	get_node(pause_setting).visible = false

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
