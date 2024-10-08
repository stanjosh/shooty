extends Node
class_name BloodSpray

const SPRAY = preload("res://scenes/effects/dark_spray.tscn")
var spray : CPUParticles2D

func _init(angle: Vector2):
	spray = SPRAY.instantiate()
	spray.direction = angle + Vector2(randf_range(-0.5, 0.5), 0)
	spray.emitting = true

func _physics_process(_delta):
	spray.direction *= randf()
	if not spray.emitting:
		queue_free()
