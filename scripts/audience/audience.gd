extends Node3D

# On Ready 
@onready var pre_audience_factory = preload("res://prefab/audience/audience_member.tscn")
@onready var pre_heckler_factory = preload("res://prefab/audience/heckler.tscn")
@onready var members = get_node('Members')
@onready var heckler = get_node('Heckler')
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var timer = get_node("Timer")

# Export
@export var chair_positions = []
@export var spawn_point = []
@export var navigation_level = []
@export var max_heckler = 5
@export var max_audience = 10
@export var starting_audience = 5

# Variable
var audience_factory
var heckler_factory
var active_hecklers = []
var audience_members = []
var collision_layer = 1

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#To do later
#@export var question_popup_rate = .5
#@export var question_popup_rate_deviance_min = -.5
#@export var question_popup_rate_deviance_max = 5
#@export var question_popup_lifespan = 2


# On start, create all audience
func _ready():
	var shuffled_array = chair_positions.duplicate()
	shuffled_array.shuffle()
	var chosen_audience = shuffled_array.slice(0, starting_audience)
	for chair_node in chosen_audience:
		print('spawning')
		_spawn_audience(get_node(chair_node), get_node(chair_node).get_node("Spawn Point"))

func _set_assigned_seat(name):
	pass

# Spawn a audience
func _spawn_audience(chair, spawn_point):
	var new_audience
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		
	new_audience = audience_factory.duplicate()
	members.add_child(new_audience)
	audience_members.append(new_audience)
	chair.occupied = true
	new_audience.position = spawn_point.global_transform.origin
	new_audience.assigned_seat = chair
	new_audience.assigned_floor = chair.get_parent().get_parent()

# If timer runs out, reload new emoji, also random chance to spawn heckler
func _on_timer_timeout():
	var children = members.get_children()
	var rand_children = randi_range(1, children.size()-1)
	children.shuffle()
	children = children.filter(func(x): return !x.in_progress)
	children = children.slice(0, rand_children)
	var num_children = children.size()
	var force = randi_range(0, num_children-1)
	for i in children:
		i.show_emoji()
	
	var occupied_chair = chair_positions.filter(func(x): return get_node(x).occupied)
	if (occupied_chair.size() < max_audience):
		spawn_point.shuffle()
		_spawn_audience(get_empty_chair(), get_node(spawn_point[0]))
	
	timer.wait_time = randi_range(4, 7)

# Destory all current Heckler
func hurt_all_hecklers():
	for heckler in active_hecklers:
		heckler.health -= 1
		if(heckler.health <= 0):
			heckler.play_death()

# Check Egg Click If Matched
func check_for_match(egg,distance):
	var emoji = egg.emoji_num
	var matched = false
	for i in members.get_children():
		if i.check_for_match(emoji):
			matched = true;
	if (matched):
		audio_manager.play_music('PickupCoin', 'Sound Effect')
		game_manager.register_match(distance)
	else:
		audio_manager.play_music('HitHurt', 'Sound Effect')		
		game_manager.register_error()

func get_empty_chair():
	var filter_chair = chair_positions.filter(func(x): return !get_node(x).occupied)
	filter_chair.shuffle()
	return get_node(filter_chair[0])

# Spawn a heckler
func spawn_heckler(audience):
	if (active_hecklers.size() < max_heckler):
		audio_manager.play_music("Boo", "Sound Effect")
		var new_heckler
		if heckler_factory == null:
			heckler_factory = pre_heckler_factory.instantiate()

		new_heckler = heckler_factory.duplicate()
		heckler.add_child(new_heckler)
		active_hecklers.append(new_heckler)
		
		new_heckler.assigned_seat = audience.assigned_seat
		new_heckler.position = audience.global_transform.origin
		audience_members.erase(audience)
		audience.queue_free()

func kill_heckler(heckler):
	active_hecklers.erase(heckler)
	heckler.assigned_seat.occupied = false
	heckler.queue_free()
