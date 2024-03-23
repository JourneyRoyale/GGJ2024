extends Node3D
class_name AudienceManager

# On Ready 
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var pre_listener_factory : PackedScene = preload("res://prefab/audience/listener.tscn")
@onready var pre_heckler_factory : PackedScene = preload("res://prefab/audience/heckler.tscn")
@onready var member : Node = get_node('Members')
@onready var heckler : Node = get_node('Heckler')
@onready var timer : Timer = get_node("Timer")

# Export
@export var spawn_point_list : Array[NodePath] = []
@export var navigation_level_list : Array[NodePath] = []
@export var target_map : NodePath

# Init variable from resources
var max_heckler : int
var starting_listener : Dictionary
var listener_rate : Dictionary
var emoji_list : Array[Shared.E_Emoji]
var emoji_variety : Dictionary
var projectile_list: Array[Dictionary]
var audience_list : Array[Dictionary]

# Local variable
var listener_factory : Listener
var heckler_factory : Heckler
var heckler_list : Array[Heckler] = [] 
var listener_node_list : Array[Listener] = []
var chair_list : Array[Chair] = []

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource

	max_heckler = level_resource.max_heckler
	starting_listener = level_resource.starting_listener
	listener_rate = level_resource.listener_rate
	emoji_variety = level_resource.emoji_variety
	emoji_list = level_resource.emoji_list
	projectile_list = level_resource.projectile_list
	audience_list = level_resource.audience_list

func _ready() -> void :
	_init_resources()
	_spawn_starting_listener()

# Spawn starting listener
func _spawn_starting_listener() -> void :
	var chair_list_shuff : Array[Chair] = chair_list.duplicate()
	chair_list_shuff.shuffle()
	
	var rng_starting_listener : int = game_manager.rng.randi_range(starting_listener["min"], starting_listener["max"])
	
	var chosen_chair : Array[Chair] = chair_list_shuff.slice(0, rng_starting_listener)
	for chair : Chair in chosen_chair:
		_spawn_listener(chair, chair.get_chair_spawn_point(), true)

# Spawn a listener
func _spawn_listener(chair : Chair, spawn_point: Node3D, is_starting : bool) -> void :
	if listener_factory == null:
		listener_factory = pre_listener_factory.instantiate()
	
	var new_listener : Listener = listener_factory.duplicate()
	new_listener.modification = _get_random_listener(chair)
	new_listener.is_seated = is_starting

	member.add_child(new_listener)
	listener_node_list.append(new_listener)
	chair.seat_entity(new_listener, spawn_point)

# Show emoji for listener not busy, and spawn listener for missing chair
func _on_timer_timeout() -> void :
	var free_listener_node_list : Array[Listener] = listener_node_list.filter(func(x): return !x.is_busy)
	
	var emoji_variety = _get_emoji_variety()
	for listener_node in free_listener_node_list:
		listener_node.show_emoji(emoji_variety)
	
	var occupied_chair_list : Array[Chair] = chair_list.filter(
		func(chair : Chair): 
			return chair.occupied and chair.can_sit
	)
	
	var sittable_chair_list : Array[Chair] = chair_list.filter(
		func(chair : Chair): 
			return chair.can_sit
	)
	
	if (occupied_chair_list.size() < sittable_chair_list.size()):
		var spawn_point_list_ran_path : Array[NodePath] = spawn_point_list.duplicate()
		spawn_point_list_ran_path.shuffle()
		_spawn_listener(_get_empty_chair(), get_node(spawn_point_list_ran_path[0]), false)
	
	timer.wait_time = game_manager.rng.randi_range(listener_rate["min"], listener_rate["max"])

# Get all unoccupied chair
func _get_empty_chair() -> Chair :
	var empty_chair_list : Array[Chair] = chair_list.filter(
		func (chair : Chair): 
			return !chair.occupied and chair.can_sit
	)
	empty_chair_list.shuffle()
	return empty_chair_list[0]

func _get_emoji_variety() -> Array[Shared.E_Emoji] :
	var chosen_emoji_list = emoji_list.duplicate()
	chosen_emoji_list.shuffle()
	chosen_emoji_list = chosen_emoji_list.slice(0,game_manager.rng.randi_range(emoji_variety["min"], emoji_variety["max"]))
	return chosen_emoji_list

func _get_randomize_projectile() -> Dictionary :
	var projectile_array : Array[Shared.E_PROJECTILE_TYPE]
	var projectile_dict : Dictionary
	for projectile in projectile_list:
		var type = projectile["type"]
		var limit = projectile["limit"]
		var matched_projectile = heckler_list.filter(
			func(x : Heckler): 
				return x.current_projectile == projectile
		).size()
		projectile_dict[type] = projectile
		
		if (matched_projectile < limit or limit == 0):
			for i in range(projectile["rate"]):
				projectile_array.append(projectile["type"])
	
	projectile_array.shuffle()
	return projectile_dict[projectile_array[0]]

func _get_random_listener(chair : Chair) -> Dictionary :
	var viable_listener_list = audience_list.filter(
		func (audience : Dictionary):
			return chair.can_sit == audience["listener"]["can_sit"]
	)
	viable_listener_list.shuffle()
	return viable_listener_list[0]

func track_chair(chair : Chair) -> void :
	chair_list.append(chair)

# Spawn a heckler
func spawn_heckler(listener : Listener) -> void :
	if (heckler_list.size() < max_heckler):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BOO), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		
		if heckler_factory == null:
			heckler_factory = pre_heckler_factory.instantiate()

		var new_heckler : Heckler
		new_heckler = heckler_factory.duplicate()
		new_heckler.modification = listener.modification
		new_heckler.current_projectile = _get_randomize_projectile()
		
		heckler.add_child(new_heckler)
		heckler_list.append(new_heckler)
		
		var chair : Chair = listener.assigned_chair
		chair.seat_entity(new_heckler, chair.get_chair_spawn_point())
		new_heckler.target_map = get_node(target_map)
		new_heckler.position.z += 1
		new_heckler.set_move_boundary()
		
		listener_node_list.erase(listener)
		listener.queue_free()

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

# Check egg match with listener
func check_for_match(egg : Egg, distance : float, player : Comedian) -> void :
	var emoji : Shared.E_Emoji = egg.emoji.current_emoji
	var matched = false
	for listener_node in listener_node_list:
		if listener_node.check_for_match(emoji):
			matched = true;
	if (matched and distance < .01):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.SUCCESS), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		game_manager.register_match(distance, player)
		hurt_all_hecklers()
	else:
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AUDIO_TYPE.SOUND_EFFECT)		
		game_manager.register_error(player)
