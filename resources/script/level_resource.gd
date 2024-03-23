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
@export var max_heckler : int = 5
@export var max_heckler_per_floor : int = 5
@export var starting_audience : Dictionary = {"min": 1, "max": 10}
@export var audience_rate : Dictionary = {"min": 4, "max": 7}

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
		"type" : Shared.E_ProjectileType.BANANNA,
		"description" : "bananna",
		"rate" : 20,
		"limit" : 0,
		"invulnerability" : .25,
		"score" : -20,
		"speed" : 10,
		"stun" : .25,
		"throw": Shared.E_ThrowType.UNDERHAND
	},
	{
		"type" : Shared.E_ProjectileType.BOOT,
		"description" : "boot",
		"rate" : 20,
		"limit" : 0,
		"knockback" : 4,
		"score" : -20,
		"speed" : 10,
		"stun" : .5,
		"throw": Shared.E_ThrowType.SLING
	},
	{
		"type" : Shared.E_ProjectileType.BOOMERANG,
		"description" : "boomerang",
		"rate" : 20,
		"limit" : 0,
		"invulnerability" : .25,
		"score" : -20,
		"speed" : 10,
		"stun" : .25,
		"throw": Shared.E_ThrowType.SLING
	},
	{
		"type" : Shared.E_ProjectileType.BRICK,
		"description" : "brick",
		"rate" : 20,
		"limit" : 0,
		"score": -20,
		"speed" : 15.0,
		"stun" : 2.0,
		"throw": Shared.E_ThrowType.SLING
	},
	{
		"type" : Shared.E_ProjectileType.GUN,
		"description" : "gun",
		"rate" : 5,
		"limit" : 1,
		"game_ender" : true,
		"score" : -50,
		"speed" : 20.0,
		"delay" : 1.0,
		"throw": Shared.E_ThrowType.SLING
	},
	{
		"type" : Shared.E_ProjectileType.MONEY,
		"description" : "money",
		"rate" : 30,
		"limit" : 0,
		"score" : 10,
		"speed" : 10.0,
		"throw": Shared.E_ThrowType.UNDERHAND
	},
	{
		"type" : Shared.E_ProjectileType.TOMATO,
		"description" : "tomato",
		"rate" : 40,
		"limit" : 0,
		"invulnerability" : .25,
		"muddle": "tomato",
		"score" : -10,
		"speed" : 15.0,
		"stun" : .25,
		"throw": Shared.E_ThrowType.SLING
	},
]

var comedian : Resource = load("res://resources/data/Level " + str(level) + "/comedian.tres")
var audience : Resource = load("res://resources/data/Level " + str(level) + "/audience.tres")
var heckler : Resource = load("res://resources/data/Level " + str(level) + "/heckler.tres")




