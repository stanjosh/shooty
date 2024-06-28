extends Node2D


const HIT_MARKER = preload("res://scenes/effects/HitMarker.tscn")
@export var speed : float = 16
@export var dropoff : float = 40
@export var heat_generated : float = 7
@export var damage : int = 5
@export var piercing : int = 0



func _physics_process(delta):
	if dropoff <= 0:
		queue_free()
	else:
		var direction = Vector2.RIGHT.rotated(rotation)
		position += direction * speed * delta * 15
		dropoff -= speed * delta

		


func _on_body_entered(body):
	var hit_marker = HIT_MARKER.instantiate()
	hit_marker.global_position = global_position
	get_parent().add_child(hit_marker)
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position.angle_to_point(body.global_position))
		damage -= randi_range(1, 3)
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1


