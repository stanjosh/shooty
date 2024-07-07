extends Node2D
class_name OrdinanceNode

const HIT_MARKER = preload("res://scenes/effects/hit_marker.tscn")
@export var speed : float = 16
@export var dropoff : float = 40
@export var damage : int = 5
@export var piercing : int = 0
@onready var hurtbox = $Hurtbox
@onready var eject_particles = $EjectParticles
@onready var gun_fire = $GunFire

func _ready():
	hurtbox.connect("body_entered", _on_body_entered)
	gun_fire.play()
	eject_particles.emitting = true

func _on_body_entered(body):
	var hit_marker = HIT_MARKER.instantiate()
	hit_marker.global_position = global_position
	get_parent().add_child(hit_marker)
	if body.has_method("take_damage"):
		body.take_damage(damage, Vector2.LEFT.rotated(global_rotation))
		damage -= randi_range(1, 3)
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1
