extends Node2D
class_name Weapon

@onready var weapon_info : ItemDataEquippable

var weapon_range : float = 0 :
	get:
		return weapon_info.base_range + (weapon_range * .15)

var cooldown : float = 0 :
	get:
		return weapon_info.base_cooldown - (cooldown * .025)

var damage : float = 0 :
	get:
		return weapon_info.base_damage + (damage * 5)
		
var knockback : float = 0 :
	get:
		return weapon_info.base_knockback + (knockback * 10)

var heat_capacity : float = 0 :
	get:
		return weapon_info.base_heat_capacity + (heat_capacity * 5)

var fire_rate : float = 0 :
	get:
		return weapon_info.base_fire_rate + fire_rate

var area : float = 0 :
	get:
		return weapon_info.base_area + (area * .5)
	
var pellets : int = 0 :
	get:
		return weapon_info.base_pellets + pellets
