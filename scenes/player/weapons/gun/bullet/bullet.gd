extends Node2D


const HIT_MARKER = preload("res://scenes/effects/hit_marker.tscn")
@export var speed : float = 16
@export var dropoff : float = 40

@export var damage : int = 5
@export var piercing : int = 10
@onready var eject_particles = $EjectParticles

@onready var gun_fire = $GunFire

func _ready():
	gun_fire.play()
	eject_particles.emitting = true

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
		body.take_damage(damage, Vector2.LEFT.rotated(global_rotation))
		damage -= randi_range(1, 3)
		if body.get("bleeds"):
			const DARK_SPRAY = preload("res://scenes/effects/dark_spray.tscn")
			var new_spray = DARK_SPRAY.instantiate()
			new_spray.rotation = global_rotation
			new_spray.global_position = body.global_position
			new_spray.scale = scale
			MapManager.current_map.call_deferred("add_child", new_spray)
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1


