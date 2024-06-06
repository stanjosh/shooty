extends Node2D
class_name Gun

@onready var gun_click = $gun_click
@onready var gun_fire = $gun_fire
@onready var gun = $Gun


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
var facing : Vector2




func _physics_process(delta):
	$PointLight2D.energy = clamp($PointLight2D.energy - 1 * delta, 0, 1)
	modulate.b = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	modulate.g = clampf(float(current_magazine * 2) / (float(magazine)), 0, 1)
	

	shot_time -= fire_rate * delta * 100 
	
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
			const BULLET = preload("res://scenes/player/weapons/projectile.tscn")
			var new_bullet = BULLET.instantiate()
			new_bullet.global_position = %angle.global_position
			new_bullet.global_rotation = %angle.global_rotation + randf_range(0, accuracy)
			new_bullet.piercing = piercing
			new_bullet.damage = damage
			new_bullet.dropoff = dropoff
			%angle.add_child(new_bullet)
			shot_time = 100
			$PointLight2D.energy = clamp($PointLight2D.energy + .4, 0, 2)
	if not overheated and current_magazine == 0:
		overheated = true
		$Overheat.start()



func _on_cooldown_timeout():
	
	if not overheated and current_magazine < magazine:
		current_magazine += 1


func _on_overheat_timeout():
	current_magazine = magazine / 2
	overheated = false
	pass # Replace with function body.
