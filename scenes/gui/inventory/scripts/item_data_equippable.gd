extends ItemData
class_name ItemDataEquippable

enum Shoots {
	STREAM,
	PROJECTILE,
	MELEE
}

@export_category("Constants")
@export var equipment_sprite : Texture2D
@export var effect_scene : PackedScene
@export var shot_type : Shoots

@export_category("Melee")
@export_range(1, 2) var base_melee_range : float = 1
@export var base_knockback : float = 1



@export_category("Shared")
@export var base_damage : int = 1
@export_range(0.1, 0.9) var base_cooldown : float = 0.5
@export var heat_generated : float  = 5
@export var base_fire_rate : float = 1
@export var base_heat_capacity : float = 100
@export var base_pellets : int = 1
@export_range(1, 2) var base_area : float = 1
@export var cutting : bool = false





var pretty_names := {
		"melee_range" : "sword range",
		"melee_area" : "sword area",
		"cooldown" : "sword cooldown",
		"damage" : "sword damage",
		"knockback" : "sword knockback",
		"heat_capacity" : "Gun heat capacity",
		"accuracy" : "Gun accuracy",
		"fire_rate" : "Gun fire rate",
		"pellets" : "Gun projectiles",
	}

var melee_range : float = 0 :
	get:
		return base_melee_range + (melee_range * .15)

var cooldown : float = 0 :
	get:
		return base_cooldown - (cooldown * .025)

var damage : float = 0 :
	get:
		return base_damage + (damage * 5)
		
var knockback : float = 0 :
	get:
		return base_knockback + (knockback * 10)

var heat_capacity : float = 0 :
	get:
		return base_heat_capacity + (heat_capacity * 5)

var fire_rate : float = 0 :
	get:
		return fire_rate + base_fire_rate

var area : float = 0 :
	get:
		return base_area + (area * .5)
	
var pellets : int = 0 :
	get:
		return pellets + base_pellets



func get_scene():
	assert(effect_scene != null)
	return effect_scene.instantiate()




