extends Node3D

@onready var pre_audience_factory = preload("res://prefab/AudienceMember.tscn")
@onready var pre_heckler_factory = preload("res://prefab/Heckler.tscn")

var audience_factory
var heckler_factory

var active_hecklers = []

@export var audience_positions = []
@onready var members = get_node('Members')

var audience_members = []

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@export var spotlight : Node3D

@export var question_popup_rate = .5
@export var question_popup_rate_deviance_min = -.5
@export var question_popup_rate_deviance_max = 5
@export var question_popup_lifespan = 2
@onready var audio_manager = get_node("/root/AudioManager")

func _ready():
	for node in audience_positions:
		print ("spawning audience member...")
		_spawn(get_node(node))
	_update()
	do_emojis()

func _spawn(node):
	var new_audience
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		new_audience = audience_factory
		members.add_child(audience_factory)
	else:
		new_audience = audience_factory.duplicate()
		members.add_child(new_audience)
	new_audience.position = node.position

func do_emojis():
	await get_tree().create_timer(randi_range(1, 5)).timeout
	var children = members.get_children()
	for i in children:
		i.clear_emoji()
	children.shuffle()
	children[0].show_emoji()
	do_emojis()
	if (randi_range(0, 1)):
		_spawn_heckler()
			
func destroy_all_hecklers():
	print("heckler: 'okay maybe hes pretty good'")
	for heckler in active_hecklers:
		heckler.queue_free()
	active_hecklers = []

func _spawn_heckler():
	var new_heckler
	if heckler_factory == null:
		heckler_factory = pre_heckler_factory.instantiate()
		new_heckler = heckler_factory
		add_child(heckler_factory)
	else:
		new_heckler = heckler_factory.duplicate()
		add_child(new_heckler)
	active_hecklers.append(new_heckler)
	
	#todo: spawn heckler and manage heckler
	
func _update():
	pass
	
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
		#print("cluck jones: 'BA DUM TISHHHHHHHHHH'")
		#_despawn_hecklers()
		##todo: maxout laugh meter
	#elif heckler:
		#for member in audience_members:
			#member.clear_thought()
		#successes = 0
		#_spawn_heckler(heckler_base)
	#elif successes > 0:
		#audio_manager.play_music('PickupCoin', 'Sound Effect')
		#print("cluck jones: 'waka waka!'")
		##todo: increase meter scaled by successes up to maximum amount
	#else:
		#audio_manager.play_music('HitHurt', 'Sound Effect')
		#print("cluck jones: 'yeesh, tough crowd...'")
		##todo: take hit to meter
	#return successes
				
	
