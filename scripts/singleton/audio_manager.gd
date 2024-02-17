extends Node3D


@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var BACKGROUND_BUS_ID = AudioServer.get_bus_index("Background")
@onready var SOUND_EFFECT_ID = AudioServer.get_bus_index("Sound Effect")

var current_music : AudioStreamPlayer
var master_volume = .5
var background_volume = .5
var sound_effect_volume = .5

# Find music under node and return
func _find_music(music_name, audio_type):
	var child_node = get_node(audio_type)
	
	if(child_node != null):
		return child_node.get_node(music_name)
	else:
		return null

# Play Music
func play_music(music_name, audio_type):
	var found_music = false;
	var new_music = _find_music(music_name, audio_type)
	
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

# Stop Music
func stop_music():
	if current_music != null:
		current_music._set_playing(false)