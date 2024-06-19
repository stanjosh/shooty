extends Area2D

const HIT_MARKER = preload("res://scenes/effects/HitMarker.tscn")
@export var speed : float = 32
@export var dropoff : float = 100
@export var user : CharacterBody2D
@onready var gun_fire = $gun_fire
var direction : Vector2
var piercing : int = 0
var damage : int = 1

func _ready():
	gun_fire.play()

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
		damage -= randi_range(1, 3)
		var hit_marker = HIT_MARKER.instantiate()
		
		hit_marker.global_position = global_position
		add_child(hit_marker)
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1
