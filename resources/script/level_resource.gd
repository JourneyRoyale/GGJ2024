extends Resource
class_name LevelResource

@export_group("Level Setup")
@export var scene : PackedScene
@export var level : int = 1
@export var time : int = 60
@export var background_music : Shared.E_BACKGROUND_MUSIC
@export var emoji_variety : Dictionary = {"min": 3, "max": 5}
@export var emoji_list : Array[Shared.E_Emoji] = [
	Shared.E_Emoji.CHICKEN_DRUMSTICK,
	Shared.E_Emoji.CHICKEN,
	Shared.E_Emoji.ALCOHOL,
	Shared.E_Emoji.KNIFE,
	Shared.E_Emoji.HEART,
	Shared.E_Emoji.CIGAR,
	Shared.E_Emoji.MONEY_BAG,
	Shared.E_Emoji.SKULL,
]

@export_group("Audience Management")
@export var max_heckler : int = 7
@export var starting_listener : Dictionary = {"min": 4, "max": 7}
@export var listener_rate : Dictionary = {"min": 4, "max": 7}
@export var audience_list : Array[Dictionary] = [
	{
		"listener" : {
			"type": Shared.E_AUDIENCE_TYPE.SHEEP,
			"description" : "sheep",
			"sprite_frame": preload("res://sprites/sprite_frame/sheep.tres"),
			"patience" : 5,
			"move_speed" : 3,
			"limit" : 0,
			"spawn_rate" : 70,
			"can_sit" : true,
		},
		"heckler" : {
			"type": Shared.E_AUDIENCE_TYPE.WOLF,
			"description" : "wolf",
			"sprite_frame": preload("res://sprites/sprite_frame/wolf.tres"),
			"health" : 2,
			"throw_speed": 10,
			"aggressive_min" : .01,
			"aggressive_max" : .99,
			"move_speed" : 0.5,
			"aggressiveness" : 2,
			"throw_delay" : 1,
			"move_time" : { "min": 2.0, "max": 5.0 },
		},
	},
	{
		"listener" : {
			"type": Shared.E_AUDIENCE_TYPE.LOG,
			"description" : "log",
			"sprite_frame": preload("res://sprites/sprite_frame/log.tres"),
			"patience" : 10,
			"move_speed" : 0,
			"rate" : 30,
			"limit" : 0,
			"spawn_rate" : 80,
			"can_sit" : false,
		},
		"heckler" : {
			"type": Shared.E_AUDIENCE_TYPE.CROCODILE,
			"description" : "crocodile",
			"sprite_frame": preload("res://sprites/sprite_frame/crocodile.tres"),
			"health" : 10,
			"throw_speed": 20,
			"aggressive_min" : .50,
			"aggressive_max" : .99,
			"move_speed" : 0.5,
			"aggressiveness" : 2,
			"throw_delay" : 1,
			"move_time" : { "min": 2.0, "max": 5.0 },
		},
	},
]

@export_group("Score Management")
@export var multiplier_increase_frequency : int = 3; #How many jokes in the combo before multiplier goes up
@export var error_amount : int = 10
@export var match_amount : int = 10
@export var annoyed_amount : int = 1

@export_group("Egg Scaling")
@export var switch_duration = 1.0
@export var scale_duration = 2.0  # Adjust this value to control the speed of scaling
@export var scale_ease = 0.5
@export var target_scale = Vector3(1.2, 1.2, 1.2)

@export_group("Projectile")
@export var projectile_list : Array[Dictionary] = [ 
	{
		"type" : Shared.E_PROJECTILE_TYPE.BANANNA,
		"description" : "bananna",
		"rate" : 20,
		"limit" : 0,
		"invulnerability" : .25,
		"score" : -20,
		"speed" : 10,
		"stun" : 2,
		"hover_time": 1,
		"despawn_time" : -1,
		"throw_type" : [
			Shared.E_THROW_TYPE.UNDERHAND,
			Shared.E_THROW_TYPE.OVERHAND,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.BOOT,
		"description" : "boot",
		"rate" : 20,
		"limit" : 0,
		"knockback" : 4,
		"score" : -20,
		"speed" : 10,
		"stun" : 1,
		"throw_type" : [
			Shared.E_THROW_TYPE.SLING,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.BOOMERANG,
		"description" : "boomerang",
		"rate" : 20,
		"limit" : 0,
		"invulnerability" : .25,
		"score" : -20,
		"speed" : 10,
		"stun" : .25,
		"throw_type" : [
			Shared.E_THROW_TYPE.SLING,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.BRICK,
		"description" : "brick",
		"rate" : 20,
		"limit" : 0,
		"score": -20,
		"speed" : 15.0,
		"stun" : 3.0,
		"despawn_time" : 0,
		"hover_time" : 1,
		"throw_type" : [
			Shared.E_THROW_TYPE.SLING,
			Shared.E_THROW_TYPE.OVERHAND,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.GUN,
		"description" : "gun",
		"rate" : 5,
		"limit" : 1,
		"game_ender" : true,
		"score" : -50,
		"speed" : 20.0,
		"delay" : 1.0,
		"throw_type" : [
			Shared.E_THROW_TYPE.NONE,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.MONEY,
		"description" : "money",
		"rate" : 0,
		"limit" : 0,
		"score" : 10,
		"speed" : 10.0,
		"despawn_time" : 5,
		"hover_time" : 1,
		"throw_type" : [
			Shared.E_THROW_TYPE.SLING,
			Shared.E_THROW_TYPE.UNDERHAND,
			Shared.E_THROW_TYPE.OVERHAND,
		],
	},
	{
		"type" : Shared.E_PROJECTILE_TYPE.TOMATO,
		"description" : "tomato",
		"rate" : 40,
		"limit" : 0,
		"invulnerability" : .25,
		"muddle": "tomato",
		"score" : -10,
		"speed" : 10.0,
		"stun" : 1,
		"throw_type" : [
			Shared.E_THROW_TYPE.SLING,
		],
	},
]

var comedian : Resource = load("res://resources/data/Level " + str(level) + "/comedian.tres")
var heckler : Resource = load("res://resources/data/Level " + str(level) + "/heckler.tres")




