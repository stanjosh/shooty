extends Node2D

const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")
const HIT_MARKER = preload("res://scenes/effects/hit_marker.tscn")
@export var speed : float = 24
@export var dropoff : float = 16
@export var heat_generated : float = 75
@export var damage : int = 3

@onready var eject_particles = $EjectParticles
@onready var gun_fire = $GunFire

var cooldown = 0
var beam_length = 0
var emitting: bool = false



func _physics_process(delta):
	
	eject_particles.emitting = true
	position = get_parent().global_position
	rotation = get_parent().global_rotation
	
	cooldown -= 1 * delta
	if emitting:

		print("emit")
		eject_particles.speed_scale = 3
		
		eject_particles.gravity = Vector2.UP * 140
		beam_length = lerpf(beam_length, dropoff, .4)
	else:
		eject_particles.speed_scale = 4
		eject_particles.gravity = Vector2.UP * 40
		beam_length = lerpf(beam_length, 0, .2)
	scale.x = beam_length
	$PointLight2D.energy = clampf(beam_length -1 , .2, 1.2)
	$PointLight2D.scale.y = lerpf(scale.x, 0, .8)
	

func _on_body_entered(body):
	var hit_marker = HIT_MARKER.instantiate()
	hit_marker.global_position = global_position
	scale.x = global_position.distance_to(body.global_position)
	if body.has_method("take_damage"):
		body.add_child(hit_marker)
		body.take_damage(damage, Vector2.LEFT.rotated(global_rotation))
		if cooldown <= 0:
			cooldown = .2
			var new_burning : Infliction = BURNING_EFFECT.instantiate()
			new_burning.period /= damage
			new_burning.position += Vector2(-1, -8)
			body.add_child(new_burning)






