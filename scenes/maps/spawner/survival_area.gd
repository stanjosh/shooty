extends Area2D
class_name SurvivalArea


var gradient_offset = 0
var active = false
var done = false

@onready var area_2d = $Area2D
@onready var cpu_particles_2d = $CPUParticles2D
@onready var point_light_2d = $PointLight2D
@onready var rect : Rect2 = $CollisionShape2D.shape.get_rect()
@onready var particle_radius = $CPUParticles2D.emission_sphere_radius
@onready var player : CharacterBody2D = get_node("/root/Game/World/player")
@onready var spawner = $EnemyArea/Spawner

func _physics_process(delta):
	if active:
		if rect.size.y > particle_radius:
			particle_radius = clampf(particle_radius + 1 * delta, particle_radius, rect.size.y)
		if gradient_offset < 0.7:
			activate_graphics(delta)
		if rect.get_center().distance_to(to_local(player.global_position)) > rect.get_area() / 2:
			player.take_damage(40 * delta, to_local(player.global_position).angle_to_point(rect.get_center()))
		
	elif done:

		if get_mobs() == false:
			explode(delta)
			
		else:
			print("still mobs")

func get_mobs():
	return true if get_overlapping_bodies().filter(func(body): return body is Mob).size() >= 1 else false

func _process(delta):
	if not active:
		if get_overlapping_bodies().filter(func(body): return body is Player):
				cpu_particles_2d.scale_amount_max = 0.5
				cpu_particles_2d.gravity = Vector2(0, -120)
				active = true

func explode(delta):
	var color := Color("White")
	gradient_offset -= 1 * delta
	var gradient : Gradient = point_light_2d.texture.gradient
	gradient.set_color(1, color)
	gradient.set_offset(1, gradient_offset)
	cpu_particles_2d.one_shot = true
	if gradient_offset <= 0 and not cpu_particles_2d.emitting:
		queue_free()


func activate_graphics(delta):
		gradient_offset = clampf(gradient_offset + 1 * delta, 0, 0.7)
		var gradient : Gradient = point_light_2d.texture.gradient
		gradient.set_offset(1, gradient_offset)


func _on_spawner_spawns_done():
	active = false
	done = true
	print("done, waiting for mobs to die")

