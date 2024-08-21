extends Resource
class_name WeaponInfo

@export var damage : int
@export var heat_generated : float
@export var fire_rate : float
@export_range(0, 5) var multishot : int
@export_range(1, 2) var damage_area : float
@export_range(1, 40) var damage_range : float
@export var speed : float = 24
@export var infliction_scene : PackedScene
