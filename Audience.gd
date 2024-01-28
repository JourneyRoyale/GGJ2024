extends Node3D

@onready var pre_audience_factory = preload("res://prefab/AudienceMember.tscn")
@onready var pre_heckler_factory = preload("res://prefab/Heckler.tscn")

var audience_factory
var heckler_factory

var active_hecklers = []

@export var audience_positions = []

var audience_members = []

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@export var spotlight : Node3D

@export var question_popup_rate = .5
@export var question_popup_rate_deviance_min = -.5
@export var question_popup_rate_deviance_max = 5
@export var question_popup_lifespan = 2

func _ready():
	for node in audience_positions:
		print ("spawning audience member...")
		_spawn(get_node(node))
	_update()

func _spawn(node):
	var new_audience
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		new_audience = audience_factory
		add_child(audience_factory)
	else:
		new_audience = audience_factory.duplicate()
		add_child(new_audience)
	new_audience.position = node.position
	audience_members.append(new_audience)

func _despawn_hecklers():
	print("heckler: 'okay maybe hes pretty good'")
	for heckler in active_hecklers:
		heckler.audience_reference.show()
		heckler.queue_free()
	active_hecklers = []

func _spawn_heckler(audience_member):
	print("heckler: 'YOU STINK!'")
	audience_member.hide()
	var new_heckler
	if heckler_factory == null:
		heckler_factory = pre_heckler_factory.instantiate()
		new_heckler = heckler_factory
		add_child(heckler_factory)
	else:
		new_heckler = heckler_factory.duplicate()
		add_child(new_heckler)
	new_heckler.audience_reference = audience_member
	new_heckler.position = audience_member.position
	active_hecklers.append(new_heckler)
	
	#todo: spawn heckler and manage heckler
	
func _update():
	audience_members.shuffle()
	for member in audience_members:
		if !member.active && !member.is_cooldown:
			member.show_thought(question_popup_lifespan)
			break
	var varied_timeout = question_popup_rate + rng.randf_range(question_popup_rate_deviance_min, question_popup_rate_deviance_max)
	await get_tree().create_timer(varied_timeout).timeout
	_update()
	
func _receive_joke(joke):
	var heckler = false
	var heckler_base
	var successes = 0
	var spotlight_bonus = false
	for member in audience_members:
		var result = member.check_for_match(joke)
		if result["heckler"]:
			heckler = true
			heckler_base = member
			break
		else:
			if result["success"]:
				successes += 1
				if spotlight.active:
					spotlight_bonus = true
			else:
				member.clear_thought()
	if spotlight_bonus:
		print("cluck jones: 'BA DUM TISHHHHHHHHHH'")
		_despawn_hecklers()
		#todo: maxout laugh meter
	elif heckler:
		for member in audience_members:
			member.clear_thought()
		successes = 0
		_spawn_heckler(heckler_base)
	elif successes > 0:
		print("cluck jones: 'waka waka!'")
		#todo: increase meter scaled by successes up to maximum amount
	else:
		print("cluck jones: 'yeesh, tough crowd...'")
		#todo: take hit to meter
	return successes
				
	
