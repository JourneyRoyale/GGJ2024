extends Node3D

@onready var pre_audience_factory = preload("res://scenes/AudienceMember.tscn")
var audience_factory

@export var audience_positions = []

var audience_members = []

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@export var question_popup_rate = .5
@export var question_popup_rate_deviance_min = -.5
@export var question_popup_rate_deviance_max = 5
@export var question_popup_lifespan = 2

func _ready():
	for position in audience_positions:
		print ("spawning audience member...")
		_spawn(position)
	_update()

func _spawn(position):
	var new_audience
	if audience_factory == null:
		audience_factory = pre_audience_factory.instantiate()
		new_audience = audience_factory
		add_child(audience_factory)
	else:
		new_audience = audience_factory.duplicate()
		add_child(new_audience)
	new_audience.position = position
	audience_members.append(new_audience)

func _spawn_heckler():
	print("heckler: 'YOU STINK!'")
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
	var successes = 0
	for member in audience_members:
		var result = member.check_for_match(joke)
		if result["heckler"]:
			heckler = true
			break
		else:
			if result["success"]:
				successes += 1
			else:
				member.clear_thought()
	if heckler:
		for member in audience_members:
			member.clear_thought()
		successes = 0
		_spawn_heckler()
	elif successes > 0:
		print("cluck jones: 'waka waka!'")
		#todo: increase meter scaled by successes up to maximum amount
	else:
		print("cluck jones: 'yeesh, tough crowd...'")
		#todo: take hit to meter
				
	
