extends Equippable
class_name EquippableMeleeWeapon




func get_scene():
	assert(effect_scene != null)
	
	return effect_scene.instantiate()
