extends RigidBody2D
class_name Grenade

@export var base_damage : float = 20

const EXPLOSION = preload("res://scenes/effects/explosion.tscn")

@onready var world = $".."
@export var speed : float = 100

var delay : bool = true
var player_damage : float = 2



func take_damage(_damage, _vector):
	if not delay:
		explode()

func explode():
	var new_splode = EXPLOSION.instantiate()
	new_splode.global_position = global_position
	new_splode.scale = Vector2(0.75, 0.75)
	world.call_deferred("add_child", new_splode)
	queue_free()

func _process(_delta):
	if global_position.distance_to(world.player.global_position) > 250:
		explode()

func _on_timer_timeout():
	delay = false
	modulate.r = 255
	modulate.g = 0
	modulate.b = 0
	$PointLight2D.enabled = true



func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.has_method("take_damage"):
		if body is Grenade and body.delay:
			apply_force(linear_velocity * angular_velocity, body.global_position)
		else:
			body.take_damage(4, global_rotation)
		

