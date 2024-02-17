extends Node3D

# On Ready 
@onready var pre_audience_factory = preload("res://prefab/audience/audience_member.tscn")
@onready var pre_heckler_factory = preload("res://prefab/audience/heckler.tscn")
@onready var members = get_node('Members')
@onready var audio_manager = get_node("/root/AudioManager")
@onready var game_manager = get_node("/root/GameManager")
@onready var timer = get_node("Timer")

# Export
@export var audience_positions = []
@export var heckler_position : Node3D
@export var max_heckler = 5

# Variable
var audience_factory
var heckler_factory
var active_hecklers = []
var audience_members = []
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#To do later
#@export var question_popup_rate = .5
#@export var question_popup_rate_deviance_min = -.5
#@export var question_popup_rate_deviance_max = 5
#@export var question_popup_lifespan = 2

# On start, create all audience
func _ready():
	for audience_node in audience_positions:
		_spawn_audience(get_node(audience_node))

# Spawn a audience
func _spawn_audience(node):
	var new_audience
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		new_audience = audience_factory
		members.add_child(audience_factory)
	else:
		new_audience = audience_factory.duplicate()
		members.add_child(new_audience)
	new_audience.position = node.position

# Spawn a heckler
func _spawn_heckler():
	audio_manager.play_music("Boo", "Sound Effect")
	var new_heckler
	if heckler_factory == null:
		heckler_factory = pre_heckler_factory.instantiate()
		new_heckler = heckler_factory
		add_child(heckler_factory)
	else:
		new_heckler = heckler_factory.duplicate()
		add_child(new_heckler)
	active_hecklers.append(new_heckler)
	if heckler_position != null:
		new_heckler.position = heckler_position.position

# If timer runs out, reload new emoji, also random chance to spawn heckler
func _on_timer_timeout():
	var children = members.get_children()
	var num_children = children.size()
	var force = randi_range(0, num_children-1)
	for i in children:
		i.clear_emoji()
		if (randi_range(0, 2) == 1 or force == children.find(i)):
			i.show_emoji()
	
	if (active_hecklers.size() < max_heckler and randi_range(0, 1)):
		_spawn_heckler()
	timer.wait_time = randi_range(0, 5)

# Destory all current Heckler
func destroy_all_hecklers():
	for heckler in active_hecklers:
		heckler.play_death()
	active_hecklers = []

# Check Egg Click If Matched
func check_for_match(emoji):
	var matched = false
	for i in members.get_children():
		if i.check_for_match(emoji):
			matched = true;
	if (matched):
		audio_manager.play_music('PickupCoin', 'Sound Effect')
		game_manager.register_match()
	else:
		audio_manager.play_music('HitHurt', 'Sound Effect')		
		game_manager.register_error()

#@export var spotlight : Node3D
#func _receive_joke(joke):
	#var heckler = false
	#var heckler_base
	#var successes = 0
	#var spotlight_bonus = false
	#for member in audience_members:
		#var result = member.check_for_match(joke)
		#if result["heckler"]:
			#heckler = true
			#heckler_base = member
			#break
		#else:
			#if result["success"]:
				#successes += 1
				##if spotlight.active:
				##	spotlight_bonus = true
			#else:
				#member.clear_thought()
	#if spotlight_bonus:
		#_despawn_hecklers()
		##todo: maxout laugh meter
	#elif heckler:
		#for member in audience_members:
			#member.clear_thought()
		#successes = 0
		#_spawn_heckler(heckler_base)
	#elif successes > 0:
		#audio_manager.play_music('PickupCoin', 'Sound Effect')
		##todo: increase meter scaled by successes up to maximum amount
	#else:
		#audio_manager.play_music('HitHurt', 'Sound Effect')
		##todo: take hit to meter
	#return successes
				
