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
	Shared.E_SOUND_EFFECT.GUN_SHOT : get_node("Sound Effect/Gun Shot"),
	Shared.E_SOUND_EFFECT.GUN_COCK : get_node("Sound Effect/Gun Cock"),
}
@onready var background_dictionary : Dictionary = {
	Shared.E_BACKGROUND_MUSIC.RAGTIME : get_node("Background/Ragtime"),
	Shared.E_BACKGROUND_MUSIC.MAIN_MENU : get_node("Background/Main Menu"),
	Shared.E_BACKGROUND_MUSIC.GAME_OVER : get_node("Background/Game Over"),
}

var master_volume : float = .5
var background_volume : float = .5
var sound_effect_volume : float = .5
var current_music : AudioStreamPlayer

func _ready():
	play_music(Shared.E_BACKGROUND_MUSIC.MAIN_MENU, Shared.E_AUDIO_TYPE.BACKGROUND)

# Find audiostream player node
func _find_music(music_name : int, audio_type : Shared.E_AUDIO_TYPE) -> AudioStreamPlayer :
	var audio_stream : AudioStreamPlayer
	match audio_type:
		Shared.E_AUDIO_TYPE.BACKGROUND:
			audio_stream = background_dictionary[music_name]
		Shared.E_AUDIO_TYPE.SOUND_EFFECT:
			audio_stream = sound_effect_dictionary[music_name]
	return audio_stream

# Play Music
func play_music(music_name : int, audio_type : Shared.E_AUDIO_TYPE) -> void :
	var new_music : AudioStreamPlayer = _find_music(music_name, audio_type)
	if new_music != null:
		match audio_type:
			Shared.E_AUDIO_TYPE.BACKGROUND:
				if current_music != null:
					current_music._set_playing(false)
				
				current_music = new_music
				new_music.play(0)
			Shared.E_AUDIO_TYPE.SOUND_EFFECT:
				new_music.play(0)
	else:
		print(audio_type, ', ', music_name, ' not found')

# Stop Music
func stop_music() -> void :
	if current_music != null:
		current_music._set_playing(false)
