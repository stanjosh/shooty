extends Resource
class_name Projectile

@export var scene : PackedScene

func get_scene():
	assert(scene != null)
	
	return scene.instantiate()
