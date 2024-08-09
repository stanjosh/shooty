extends Resource
class_name WeaponInfo

@export var damage : int
@export var heat_generated : float
@export var fire_rate : float
@export_range(0, 5) var pellets : int
@export_range(1, 2) var area : float
@export_range(1, 40) var shot_range : float
@export var knockback : float
@export var speed : float = 24
@export var piercing : int = 1
@export_range(0, 100) var infliction_chance : float = 0

