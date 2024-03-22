extends Node3D
class_name AudienceManager

# On Ready 
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var pre_audience_factory : PackedScene = preload("res://prefab/audience/audience.tscn")
@onready var pre_heckler_factory : PackedScene = preload("res://prefab/audience/heckler.tscn")
@onready var member : Node = get_node('Members')
@onready var heckler : Node = get_node('Heckler')
@onready var timer : Timer = get_node("Timer")

# Export
@export var spawn_point_list : Array[NodePath] = []
@export var navigation_level_list : Array[NodePath] = []

# Init variable from resources
var max_heckler : int
var starting_audience : Dictionary
var audience_rate : Dictionary
var emoji_list : Array[Shared.E_Emoji]
var emoji_variety : Dictionary
var projectile_list: Array[Dictionary]

# Local variable
var audience_factory : Audience
var heckler_factory : Heckler
var heckler_list : Array[Heckler] = [] 
var audience_node_list : Array[Audience] = []
var chair_list : Array[Chair] = []

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource

	max_heckler = level_resource.max_heckler
	starting_audience = level_resource.starting_audience
	audience_rate = level_resource.audience_rate
	emoji_variety = level_resource.emoji_variety
	emoji_list = level_resource.emoji_list
	projectile_list = level_resource.projectile_list

func _ready() -> void :
	_init_resources()
	_spawn_starting_audience()

# Spawn starting audience
func _spawn_starting_audience() -> void :
	var chair_list_shuff : Array[Chair] = chair_list.duplicate()
	chair_list_shuff.shuffle()
	
	var rng_starting_audience : int = game_manager.rng.randi_range( starting_audience["min"], starting_audience["max"])
	
	var chosen_chair : Array[Chair] = chair_list_shuff.slice(0, rng_starting_audience)
	for chair : Chair in chosen_chair:
		_spawn_audience(chair, chair.get_chair_spawn_point())

# Spawn a audience
func _spawn_audience(chair : Chair, spawn_point: Node3D) -> void :
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		
	var new_audience : Audience = audience_factory.duplicate()
	member.add_child(new_audience)
	audience_node_list.append(new_audience)
	chair.seat_entity(new_audience, spawn_point)
	new_audience.move_to_seat()

# Show emoji for audience not busy, and spawn audience for missing chair
func _on_timer_timeout() -> void :
	var free_audience_node_list : Array[Audience] = audience_node_list.filter(func(x): return !x.is_busy)
	
	var emoji_variety = _get_emoji_variety()
	for audience_node in free_audience_node_list:
		audience_node.show_emoji(emoji_variety)
	
	var occupied_chair_list : Array[Chair] = chair_list.filter(func(x): return x.occupied)
	if (occupied_chair_list.size() < chair_list.size()):
		var spawn_point_list_ran_path : Array[NodePath] = spawn_point_list.duplicate()
		spawn_point_list_ran_path.shuffle()
		_spawn_audience(_get_empty_chair(), get_node(spawn_point_list_ran_path[0]))
	
	timer.wait_time = game_manager.rng.randi_range(audience_rate["min"], audience_rate["max"])

# Get all unoccupied chair
func _get_empty_chair() -> Chair :
	var empty_chair_list : Array[Chair] = chair_list.filter(func(x): return !x.occupied)
	empty_chair_list.shuffle()
	return empty_chair_list[0]

func _get_emoji_variety() -> Array[Shared.E_Emoji] :
	var chosen_emoji_list = emoji_list.duplicate()
	chosen_emoji_list.shuffle()
	chosen_emoji_list = chosen_emoji_list.slice(0,game_manager.rng.randi_range(emoji_variety["min"], emoji_variety["max"]))
	return chosen_emoji_list

func track_chair(chair : Chair) -> void :
	chair_list.append(chair)

# Spawn a heckler
func spawn_heckler(audience) -> void :
	if (heckler_list.size() < max_heckler):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BOO), Shared.E_AudioType.SOUND_EFFECT)
		
		if heckler_factory == null:
			heckler_factory = pre_heckler_factory.instantiate()

		var new_heckler : Heckler
		new_heckler = heckler_factory.duplicate()
		new_heckler.current_projectile = get_randomize_projectile()
		
		heckler.add_child(new_heckler)
		heckler_list.append(new_heckler)
		
		var chair : Chair = audience.assigned_chair
		chair.seat_entity(new_heckler, chair.get_chair_spawn_point())
		new_heckler.position.z += 1
		new_heckler.set_move_boundary()
		
		audience_node_list.erase(audience)
		audience.queue_free()

# Kill Heckler
func kill_heckler(heckler : Heckler) -> void :
	heckler_list.erase(heckler)
	heckler.assigned_chair.clear_chair()
	heckler.queue_free()

# Hurt all current Heckler
func hurt_all_hecklers() -> void :
	for heckler : Heckler in heckler_list:
		heckler.health -= 1
		if(heckler.health <= 0):
			heckler.play_death()

# Check egg match with audience
func check_for_match(egg : Egg, distance : float) -> void :
	var emoji : Shared.E_Emoji = egg.emoji.current_emoji
	var matched = false
	for audience_node in audience_node_list:
		if audience_node.check_for_match(emoji):
			matched = true;
	if (matched and distance < .01):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.SUCCESS), Shared.E_AudioType.SOUND_EFFECT)
		game_manager.register_match(distance)
		hurt_all_hecklers()
	else:
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AudioType.SOUND_EFFECT)		
		game_manager.register_error()

func get_randomize_projectile() -> Dictionary :
	var projectile_array : Array[Shared.E_ProjectileType]
	var projectile_dict : Dictionary
	for projectile in projectile_list:
		var type = projectile["type"]
		var limit = projectile["limit"]
		var matched_projectile = heckler_list.filter(func(x : Heckler): return x.current_projectile == projectile).size()
		projectile_dict[type] = projectile
		
		if (matched_projectile < limit or limit == 0):
			for i in range(projectile["rate"]):
				projectile_array.append(projectile["type"])
	
	projectile_array.shuffle()
	return projectile_dict[projectile_array[0]]
