extends Node2D
class_name WeaponOrdinance

const HIT_MARKER = preload("res://scenes/effects/hit_marker.tscn")

var weapon_info : WeaponInfo

var firing : bool = false

var weapon_range : float = 0 :
	get:
		return weapon_info.range + (weapon_range * .15)

var infliction_chance : float = 0 :
	get:
		return weapon_info.infliction_chance - (infliction_chance)

var damage : float = 0 :
	get:
		return weapon_info.damage + (damage * 5)
		
var knockback : float = 0 :
	get:
		return weapon_info.knockback + (knockback * 10)

var fire_rate : float = 0 :
	get:
		return weapon_info.fire_rate + fire_rate

var area : float = 0 :
	get:
		return weapon_info.area + (area * .5)

var heat_generated : float = 0 :
	get:
		return weapon_info.heat_generated - heat_generated

func fire():
	pass


