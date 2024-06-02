extends Area2D

@export var speed : float = 32
@export var dropoff : float = 100
@export var user : CharacterBody2D
var direction : Vector2
var piercing : int = 0
var damage : int = 1

func _physics_process(delta):
	if dropoff <= 0:
		queue_free()
	else:
		direction = Vector2.RIGHT.rotated(rotation)
		position += direction * speed * delta * 15
		dropoff -= speed * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage, global_rotation)
		damage -= randf_range(1, 3)
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1
