extends Node2D

const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")
const HIT_MARKER = preload("res://scenes/effects/hit_marker.tscn")
@export var speed : float = 24
@export var dropoff : float = 16
@export var heat_generated : float = 75
@export var damage : int = 3

@onready var eject_particles = $projectile/EjectParticles


@onready var projectile : Area2D = $projectile
@onready var gun_fire : AudioStreamPlayer2D= $projectile/GunFire
@onready var point_light_2d : PointLight2D = $projectile/PointLight2D
@onready var hit_particles : CPUParticles2D = $HitParticles
@onready var ray_cast_2d = $projectile/RayCast2D


var cooldown = 0
var beam_length = 0
var emitting: bool = false



func _physics_process(delta):
	hit_particles.emitting = false
	eject_particles.emitting = true
	cooldown -= 1 * delta
	if emitting:
		print("emit")
		eject_particles.speed_scale = 3
		eject_particles.gravity = Vector2.UP * 140
		if ray_cast_2d.is_colliding():
			var pos = ray_cast_2d.get_collision_point()
			if ray_cast_2d.get_collision_mask_value(8) or ray_cast_2d.get_collision_mask_value(9):
				print(dropoff * (position.distance_to(to_local(pos)) * .01))
				beam_length = (position.distance_to(to_local(pos))) / dropoff + 3
			hit_particles.emitting = true
			hit_particles.global_position = pos
			hit_particles.emission_sphere_radius = beam_length / dropoff
		beam_length = lerpf(beam_length, dropoff, .04)
	else:
		eject_particles.speed_scale = 4
		eject_particles.gravity = Vector2.UP * 40
		beam_length = lerpf(beam_length, 0, .2)
	projectile.set_deferred("position", get_parent().global_position)
	projectile.set_deferred("rotation", get_parent().global_rotation)
	projectile.set_deferred("scale", Vector2(beam_length, 1))
	
	point_light_2d.energy = clampf(beam_length -1 , .2, 1.2)
	point_light_2d.scale.y = lerpf(scale.x, 0, .8)
	

func _on_projectile_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage, Vector2.LEFT.rotated(randf()))
		if cooldown <= 0:
			cooldown = .2
			var new_burning : Infliction = BURNING_EFFECT.instantiate()
			new_burning.period /= damage
			new_burning.position += Vector2(-1, -8)
			body.call_deferred("add_child", new_burning)
