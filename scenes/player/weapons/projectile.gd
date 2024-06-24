extends Resource
class_name Projectile

@export var scene : PackedScene

@export var speed : float
@export var dropoff : float
@export var heat_generated : float
@export var damage : int
@export var piercing : int

func get_scene():
	assert(scene != null)
	return scene.instantiate()
