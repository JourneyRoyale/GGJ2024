extends Node3D
class_name AudioManager

@onready var MASTER_BUS_ID : int = AudioServer.get_bus_index("Master")
@onready var BACKGROUND_BUS_ID : int = AudioServer.get_bus_index("Background")
@onready var SOUND_EFFECT_ID : int = AudioServer.get_bus_index("Sound Effect")
@onready var sound_effect_dictionary : Dictionary = {
	Shared.E_SOUND_EFFECT.BOO : get_node("Sound Effect/Boo"),
	Shared.E_SOUND_EFFECT.BWACK : get_node("Sound Effect/Bwack"),
	Shared.E_SOUND_EFFECT.HURT : get_node("Sound Effect/Hurt"),
	Shared.E_SOUND_EFFECT.SUCCESS : get_node("Sound Effect/Success"),
	Shared.E_SOUND_EFFECT.POWER_UP : get_node("Sound Effect/Power Up"),
}
@onready var background_dictionary : Dictionary = {
	Shared.E_BACKGROUND_MUSIC.RAGTIME : get_node("Background/Ragtime"),
}

var master_volume : float = 0
var background_volume : float = .5
var sound_effect_volume : float = .5
var current_music : AudioStreamPlayer

# Find audiostream player node
func _find_music(music_name : int, audio_type : Shared.E_AudioType) -> AudioStreamPlayer :
	var audio_stream : AudioStreamPlayer
	match audio_type:
		Shared.E_AudioType.BACKGROUND:
			audio_stream = background_dictionary[music_name]
		Shared.E_AudioType.SOUND_EFFECT:
			audio_stream = sound_effect_dictionary[music_name]
	return audio_stream

# Play Music
func play_music(music_name : int, audio_type : Shared.E_AudioType) -> void :
	var new_music : AudioStreamPlayer = _find_music(music_name, audio_type)
	if new_music != null:
		match audio_type:
			Shared.E_AudioType.BACKGROUND:
				if current_music != null:
					current_music._set_playing(false)
				
				current_music = new_music
				new_music.play(0)
			Shared.E_AudioType.SOUND_EFFECT:
				new_music.play(0)
	else:
		print(audio_type, ', ', music_name, ' not found')

# Stop Music
func stop_music() -> void :
	if current_music != null:
		current_music._set_playing(false)
