extends Node3D
class_name AudienceManager

# On Ready 
@onready var game_manager : GameManager = get_node("/root/Game_Manager")
@onready var audio_manager : AudioManager = get_node("/root/Audio_Manager")
@onready var pre_listener_factory : PackedScene = preload("res://prefab/audience/listener.tscn")
@onready var pre_heckler_factory : PackedScene = preload("res://prefab/audience/heckler.tscn")
@onready var member_hold : Node = get_node('Members')
@onready var heckler_hold : Node = get_node('Heckler')
@onready var projectile_hold : Node = get_node('Projectile')
@onready var emoji_timer : Timer = get_node("Emoji Timer")
@onready var spawn_timer : Timer = get_node("Spawn Timer")

# Resource Variable
var max_heckler : int
var starting_listener : Dictionary
var emoji_list : Array[Shared.E_Emoji]
var emoji_variety : Dictionary
var projectile_list: Array[Dictionary]
var audience_list : Array[Dictionary]
var spawn_rate : Dictionary
var emoji_rate : Dictionary

# Local variable
var listener_factory : Listener
var heckler_factory : Heckler
var heckler_list : Array[Heckler] = [] 
var listener_node_list : Array[Listener] = []
var chair_list : Array[Chair] = []
var target_map : TargetMap
var spawn_point_list : Array[Node] = []

func _init_resources() -> void :
	var level_resource : LevelResource = game_manager.level_resource

	max_heckler = level_resource.max_heckler
	starting_listener = level_resource.starting_listener
	emoji_rate = level_resource.emoji_rate
	spawn_rate = level_resource.spawn_rate
	emoji_variety = level_resource.emoji_variety
	emoji_list = level_resource.emoji_list
	projectile_list = level_resource.projectile_list
	audience_list = level_resource.audience_list
	
	target_map = get_tree().get_nodes_in_group("TargetMap")[0] as TargetMap
	spawn_point_list = get_tree().get_nodes_in_group("SpawnPoint")
	for node : Node in get_tree().get_nodes_in_group("Chair"):
		if node != null and node is Chair:
			chair_list.append(node as Chair)

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
	new_listener.init_variable(_get_random_listener(chair), is_starting)
	
	member_hold.add_child(new_listener)
	listener_node_list.append(new_listener)
	
	chair.seat_audience(new_listener, spawn_point)

# Show emoji for listener not busy, and spawn listener for missing chair
func _on_emoji_timer_timeout() -> void :
	var free_listener_node_list : Array[Listener] = listener_node_list.filter(func(x): return !x.is_busy)
	
	# Get emoji for listener to show
	var emoji_variety : Array[Shared.E_Emoji] = _get_emoji_variety()
	for listener_node in free_listener_node_list:
		listener_node.show_emoji(emoji_variety)
	
	emoji_timer.wait_time = game_manager.rng.randi_range(emoji_rate["min"], emoji_rate["max"])


func _on_spawn_timer_timeout():
	var occupied_chair_list : Array[Chair] = chair_list.filter(
		func _is_occupied(chair : Chair): 
			return chair.occupied and chair.can_sit
	)
	
	var sittable_chair_list : Array[Chair] = chair_list.filter(
		func _is_sittable(chair : Chair): 
			return chair.can_sit
	)
	
	# Spawn listener and assign them chair
	if (occupied_chair_list.size() < sittable_chair_list.size()):
		var empty_chair = _get_empty_chair()
		var closet_chair = _get_closet_spawn(empty_chair)
		_spawn_listener(empty_chair, closet_chair, false)
	
	spawn_timer.wait_time = game_manager.rng.randi_range(spawn_rate["min"], spawn_rate["max"])


# Get all unoccupied chair
func _get_empty_chair() -> Chair :
	var empty_chair_list : Array[Chair] = chair_list.filter(
		func _is_occupied(chair : Chair): 
			return !chair.occupied and chair.can_sit
	)
	empty_chair_list.shuffle()
	return empty_chair_list[0]

func _get_closet_spawn(chair : Chair) -> Node :
	var closest_distance : float = spawn_point_list[0].global_transform.origin.distance_to(chair.global_transform.origin)
	var closest_spawn : Node = spawn_point_list[0]

	for position in spawn_point_list:
		var distance = position.global_transform.origin.distance_to(chair.global_transform.origin)
		if (distance < closest_distance):
			closest_distance = distance
			closest_spawn = position
	return closest_spawn

# Get a variety number of unique emoji for listener to show
func _get_emoji_variety() -> Array[Shared.E_Emoji] :
	var chosen_emoji_list : Array[Shared.E_Emoji] = emoji_list.duplicate()
	chosen_emoji_list.shuffle()
	chosen_emoji_list = chosen_emoji_list.slice(0, game_manager.rng.randi_range(emoji_variety["min"], emoji_variety["max"]))
	return chosen_emoji_list

# Get a random projectile that pairs with the chair
func _get_randomize_projectile(chair : Chair) -> Dictionary :
	var projectile_array : Array[Shared.E_PROJECTILE_TYPE]
	var projectile_dict : Dictionary
	
	# Filter projectile by what chair can throw
	var throwable_projectile : Array[Dictionary] = projectile_list.filter(
		func _can_be_thrown(projectile_info : Dictionary):
			return projectile_info["throw_type"].filter(
				func _is_throwable_from_chair(throw_type : Shared.E_THROW_TYPE):
					return chair.get_allowed_throw_type().keys().has(throw_type)
			).size() > 0
	)
	
	# Check if any projectile exceed limit, if not add to pot
	for projectile in throwable_projectile:
		var type : Shared.E_PROJECTILE_TYPE = projectile["type"]
		var limit : int = projectile["limit"]
		
		# Get all current heckler projectile that match
		var matched_projectile : int = heckler_list.filter(
			func _does_projectile_match(x : Heckler): 
				return x.current_projectile == projectile
		).size()
		
		# Check if limit exceeded and add rate to pot
		if (matched_projectile < limit or limit == 0):
			for i in range(projectile["rate"]):
				projectile_array.append(projectile["type"])
		
		# Copy projectile_list as a dictionary to allow easier selection
		projectile_dict[type] = projectile
	
	projectile_array.shuffle()
	return projectile_dict[projectile_array[0]]

# Get random throwing type for projectile base on chair percentage chance
func _get_random_throw_type(projectile : Dictionary, chair : Chair) -> Shared.E_THROW_TYPE :
	var rng_throw_type_pile : Array[Shared.E_THROW_TYPE] = []
	
	# Loop through projectile throw type
	for throw_type in projectile["throw_type"]:
		# Get the percentage of that type is allowed
		if(chair.get_allowed_throw_type().has(throw_type)):
			for i in range(chair.get_allowed_throw_type()[throw_type]):
				rng_throw_type_pile.append(throw_type)
	
	rng_throw_type_pile.shuffle()
	return rng_throw_type_pile[0]

# Get a random listener that can sit
func _get_random_listener(chair : Chair) -> Dictionary :
	var viable_listener_list : Array[Dictionary] = audience_list.filter(
		func (audience : Dictionary):
			return chair.can_sit == audience["listener"]["can_sit"]
	)
	viable_listener_list.shuffle()
	return viable_listener_list[0]

# Spawn a heckler
func spawn_heckler(listener : Listener) -> void :
	if (heckler_list.size() < max_heckler):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.BOO), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		
		if heckler_factory == null:
			heckler_factory = pre_heckler_factory.instantiate()
		
		var projectile : Dictionary = _get_randomize_projectile(listener.assigned_chair)
		var throw_type : Shared.E_THROW_TYPE = _get_random_throw_type(projectile, listener.assigned_chair)
		
		var new_heckler : Heckler = heckler_factory.duplicate()
		new_heckler.init_variable(listener.modification, projectile, throw_type, target_map, projectile_hold)
		heckler_hold.add_child(new_heckler)
		heckler_list.append(new_heckler)
		
		var chair : Chair = listener.assigned_chair
		chair.seat_audience(new_heckler, chair.get_chair_spawn_point())
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

# Check if egg match with listener
func check_for_match(egg : Egg, distance : float, player : Comedian) -> void :
	var emoji : Shared.E_Emoji = egg.emoji.current_emoji
	var matched : bool = false
	for listener_node in listener_node_list:
		if listener_node.check_for_match(emoji):
			matched = true;
	if (matched):
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.SUCCESS), Shared.E_AUDIO_TYPE.SOUND_EFFECT)
		game_manager.register_match(distance, player)
		hurt_all_hecklers()
	else:
		audio_manager.play_music(int(Shared.E_SOUND_EFFECT.HURT), Shared.E_AUDIO_TYPE.SOUND_EFFECT)		
		game_manager.register_error(player)
