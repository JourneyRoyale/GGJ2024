extends Resource
class_name LevelResource

@export_group("Level Setup")
@export var scene : PackedScene
@export var level : int = 1
@export var time : int = 60
@export var background_music : Shared.E_BACKGROUND_MUSIC
@export var emoji_list : Array[Shared.E_Emoji]
@export var emoji_variety : Dictionary = {"min": 3, "max": 5}
@export_group("Audience Management")
@export var max_heckler : int = 5
@export var max_heckler_per_floor : int = 5
@export var starting_audience : Dictionary = {"min": 1, "max": 10}
@export var audience_rate : Dictionary = {"min": 4, "max": 7}
@export_group("Score Management")
@export var multiplier_increase_frequency : int = 3; #How many jokes in the combo before multiplier goes up
@export var error_amount : int = 10
@export var match_amount : int = 10
@export var hit_amount : int = 20
@export var annoyed_amount : int = 1
@export_group("Egg Scaling")
@export var scale_duration = 2.0  # Adjust this value to control the speed of scaling
@export var target_scale = Vector3(1.2, 1.2, 1.2)

var comedian : Resource = load("res://resources/data/Level " + str(level) + "/comedian.tres")
var audience : Resource = load("res://resources/data/Level " + str(level) + "/audience.tres")
var heckler : Resource = load("res://resources/data/Level " + str(level) + "/heckler.tres")




