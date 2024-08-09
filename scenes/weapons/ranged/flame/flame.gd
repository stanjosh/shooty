extends WeaponOrdinance

const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")

@onready var eject_particles = $projectile/EjectParticles
@onready var projectile : Area2D = $projectile
@onready var gun_fire : AudioStreamPlayer2D= $projectile/GunFire
@onready var hit_particles : CPUParticles2D = $HitParticles
@onready var ray_cast_2d = $projectile/RayCast2D
@onready var point_light_2d = $PointLight2D

var beam_length = 0

func _physics_process(delta):

	hit_particles.emitting = false
	eject_particles.emitting = true
	if firing:
		eject_particles.speed_scale = 3
		eject_particles.gravity = Vector2.UP * 140
		if ray_cast_2d.is_colliding():
			var pos = ray_cast_2d.get_collision_point()
			if ray_cast_2d.get_collision_mask_value(8) or ray_cast_2d.get_collision_mask_value(9):
				beam_length = (position.distance_to(to_local(pos))) / weapon_info.shot_range
			hit_particles.emitting = true
			hit_particles.global_position = pos
			hit_particles.emission_sphere_radius = beam_length / weapon_info.shot_range
		beam_length = lerpf(beam_length, weapon_info.shot_range, .04)
		increase_heat_level.emit(heat_generated * 10 * delta)
	else:
		eject_particles.speed_scale = 3
		eject_particles.gravity = Vector2.UP * 40
		beam_length = lerpf(beam_length, 0, .2)
	projectile.set_deferred("position", get_parent().global_position)
	projectile.set_deferred("rotation", get_parent().global_rotation)
	projectile.set_deferred("scale", Vector2(beam_length, 1))
	
	point_light_2d.energy = lerpf(0, beam_length, .075)
	point_light_2d.scale.y = lerpf(0, beam_length, .25)
	point_light_2d.scale.x = lerpf(0, beam_length, .125)
	
	

func _on_projectile_body_entered(body):
	if randf_range(0, 100) > infliction_chance :
		var new_burning : Infliction = BURNING_EFFECT.instantiate()
		new_burning.period = damage
		new_burning.position += Vector2(-1, -8)
		body.call_deferred("add_child", new_burning)
