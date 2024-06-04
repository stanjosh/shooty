extends Node2D
class_name Gun

@onready var gun_click = $gun_click
@onready var gun_fire = $gun_fire
@onready var target = global_position
@onready var gun = $pivot/Gun
const GRENADE = preload("res://scenes/player/Grenade.tscn")

@export var damage : int = 10
@export var piercing : int = 1
@export var magazine : int = 12
@export var fire_rate : int = 6
@export var accuracy : float = .03
@export var pellets : int = 1
@export var dropoff : float = 15
var overheated : bool = false


@onready var world = $"../.."


var current_magazine : int = magazine
var shot_time : float = 0
var grenade_timer : float = 1
var max_grenades : int = 3
var facing : Vector2




func _physics_process(delta):
	$pivot/PointLight2D.energy = clamp($pivot/PointLight2D.energy - 1 * delta, 0, 1)
	modulate.b = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	modulate.g = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	
	
	if grenade_timer <= 1:
		grenade_timer += 1 * delta

		
	shot_time -= fire_rate * delta * 100 
	
	target = get_global_mouse_position()

	look_at(target)
	
	
	var deadzone = 0.5
	#var controllerangle = Vector2.ZERO
	var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var yAxisUD = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
		rotation = Vector2(xAxisRL, yAxisUD).angle()
		facing = Vector2(xAxisRL, yAxisUD)
	
	
	facing = gun.global_position.direction_to($"..".global_position)
	

	
	
	gun.flip_v = true if facing.x > 0 else false
	gun.z_index = 2 if facing.y > .25 else 4



func shoot(_delta):
	if not overheated and shot_time <= 0:
		gun_fire.play()
		current_magazine -= 1
		for n in pellets:
			const BULLET = preload("res://scenes/player/projectile.tscn")
			var new_bullet = BULLET.instantiate()
			new_bullet.global_position = %barrel.global_position
			new_bullet.global_rotation = %barrel.global_rotation + randf_range(0, accuracy)
			new_bullet.piercing = piercing
			new_bullet.damage = damage
			new_bullet.dropoff = dropoff
			%barrel.add_child(new_bullet)
			shot_time = 100
			$pivot/PointLight2D.energy = clamp($pivot/PointLight2D.energy + .4, 0, 2)
	if not overheated and current_magazine == 0:
		overheated = true
		$Overheat.start()

func throw_grenade():
	if grenade_timer >= 1 and world.active_grenades.size() < max_grenades:
		var grenade = GRENADE.instantiate() as RigidBody2D
		grenade.global_position = %barrel.global_position
		grenade.speed = global_position.distance_to(get_global_mouse_position())
		grenade.linear_velocity = (get_global_mouse_position() - global_position).normalized() * grenade.speed
		

		world.add_child(grenade)
		grenade_timer = 0



func _on_cooldown_timeout():
	
	if not overheated and current_magazine < magazine:
		current_magazine += 1


func _on_overheat_timeout():
	current_magazine = magazine / 2
	overheated = false
	pass # Replace with function body.
