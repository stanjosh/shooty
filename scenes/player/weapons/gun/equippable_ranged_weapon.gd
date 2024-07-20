extends Equippable
class_name EquippableRangedWeapon


enum Shoots {
	STREAM,
	PROJECTILE
}
@export var shot_type : Shoots

func get_scene():
	assert(effect_scene != null)
	
	return effect_scene.instantiate()
