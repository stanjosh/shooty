extends Equippable
class_name EquippableMeleeWeapon

@export_range(1, 2) var base_melee_range : float = 1
@export_range(1, 2) var base_melee_area : float = 1
@export_range(0.2, 1) var base_cooldown : float = 1
@export var base_knockback : float = 20
@export var base_damage : int = 20

@export var speed : float = 40

var melee_range : float = 0 :
	get:
		return base_melee_range + (melee_range * .15)

var melee_area : float = 0 :
	get:
		return base_melee_area + (melee_area * .15)
		
var cooldown : float = 0 :
	get:
		return base_cooldown - (cooldown * .025)

var damage : float = 0 :
	get:
		return base_damage + (damage * 5)
		
var knockback : float = 0 :
	get:
		return base_knockback + (knockback * 10)

var status : Dictionary

var pretty_names := {
		"melee_range" : "sword range",
		"melee_area" : "sword area",
		"cooldown" : "sword cooldown",
		"damage" : "sword damage",
		"knockback" : "sword knockback"
	}


func get_scene():
	assert(effect_scene != null)
	
	return effect_scene.instantiate()
