extends Node2D


const mine = preload("res://scenes/player/weapons/mine.tscn")
@onready var world = $"../../.."
@export var grenade_timer : float = 1
@export var max_grenades : int = 3
@export_range(1, 3) var launch_speed : float = 1
@export var recharge_speed : float = 1

func _physics_process(delta):
	if grenade_timer <= 1:
		grenade_timer += recharge_speed * delta
		
func throw_grenade():
	if grenade_timer >= 1 and world.active_grenades.size() < max_grenades:
		var grenade = mine.instantiate() as RigidBody2D
		grenade.global_position = %angle.global_position
		grenade.speed = global_position.distance_to(get_global_mouse_position())
		grenade.linear_velocity = (get_global_mouse_position() - global_position).normalized() * (grenade.speed * launch_speed)
		

		world.add_child(grenade)
		grenade_timer = 0
