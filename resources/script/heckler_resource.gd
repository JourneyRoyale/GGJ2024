extends Resource
class_name HecklerResource

@export var move_speed : float = 0.5
@export var aggressiveness : float = 2
@export var throw_delay : float = 1
@export var move_time : Dictionary = { "min": 2.0, "max": 5.0 }
@export var projectile_allowed : Array[Shared.E_ProjectileType] = [
	Shared.E_ProjectileType.BANANNA,
	Shared.E_ProjectileType.BOOMERANG,
	Shared.E_ProjectileType.BOOT,
	Shared.E_ProjectileType.BRICK,
	Shared.E_ProjectileType.GUN,
	Shared.E_ProjectileType.MONEY,
	Shared.E_ProjectileType.TOMATO,
]
