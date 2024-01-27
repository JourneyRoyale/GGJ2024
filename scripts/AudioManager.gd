extends Node3D


@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var BACKGROUND_BUS_ID = AudioServer.get_bus_index("Background")
@onready var SOUND_EFFECT_ID = AudioServer.get_bus_index("Sound Effect")

var current_music : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z:
			_play_music('Refractor','Background')
		elif event.keycode == KEY_X:
			_play_music('Arcade','Sound Effect')


func _play_music(music_name, audio_type):
	var found_music = false;
	var new_music = _find_music(music_name, audio_type)
	print(new_music)

	
	if new_music != null:
		match audio_type:
			"Background":
				if current_music != null:
					current_music._set_playing(false)
				current_music = new_music
				new_music.play(0)
				found_music = true
			"Sound Effect":
				new_music.play(0)
	else:
		print(audio_type, ', ', music_name, ' not found')

func _find_music(music_name, audio_type):
	var child_node = get_node(audio_type)

	if(child_node != null):
		return child_node.get_node(music_name)
	else:
		return null

func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < .05)

func _on_sound_effect_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SOUND_EFFECT_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SOUND_EFFECT_ID, value < .05)

func _on_background_slider_value_changed(value):
	AudioServer.set_bus_volume_db(BACKGROUND_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(BACKGROUND_BUS_ID, value < .05)
