extends Node2D

var grenade_timer : float = 1
var max_grenades : int = 3
@onready var world = $"../.."
const GRENADE = preload("res://scenes/player/Grenade.tscn")

func throw_grenade():
	if grenade_timer >= 1:
		var grenade = GRENADE.instantiate() as RigidBody2D
		grenade.global_position = %Barrel.global_position
		grenade.speed = global_position.distance_to(get_global_mouse_position())
		grenade.linear_velocity = (get_global_mouse_position() - global_position).normalized() * grenade.speed
		

		world.add_child(grenade)
		grenade_timer = 0
