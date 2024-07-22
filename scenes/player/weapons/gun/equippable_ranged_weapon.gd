extends Equippable
class_name EquippableRangedWeapon


@export var base_fire_rate : float = 3
@export var base_accuracy : float = 85
@export var base_pellets : int = 1
@export var base_cooldown : float = .25
@export var heat_generated : float = 10
@export var base_heat_capacity : float = 100
var heat_capacity : float = 0 :
	get:
		return base_heat_capacity + (heat_capacity * 5)


var fire_rate : float = 0 :
	get:
		return fire_rate + base_fire_rate

var accuracy : float = 0 :
	get:
		return base_accuracy + (accuracy * .5)
	
var pellets : int = 0 :
	get:
		return pellets + base_pellets



var cooldown : float = 0 :
	get:
		return base_cooldown + (cooldown * .125)


enum Shoots {
	STREAM,
	PROJECTILE
}
@export var shot_type : Shoots

func get_scene():
	assert(effect_scene != null)
	
	return effect_scene.instantiate()
