extends Resource
class_name Ordinance

@export var scene : PackedScene
enum Shoots {
	STREAM,
	PROJECTILE
}
@export var shot_type : Shoots

func get_scene():
	assert(scene != null)
	
	return scene.instantiate()
