extends Resource
class_name Ordinance


enum FireType {
	STREAM,
	PROJECTILE
}
@export var scene : PackedScene
@export var heat_generated : float
@export var fire_type : FireType

func activate():
	assert(scene != null)
	return scene.instantiate()
