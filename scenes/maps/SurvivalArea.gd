extends Area2D
@onready var point_light_2d = $PointLight2D

var gradient_offset = 0
var active = false
var done = false

@onready var rect : Rect2 = $CollisionShape2D.shape.get_rect()
@onready var particle_radius = $CPUParticles2D.emission_sphere_radius
		
func _physics_process(delta):
	if active:
		if rect.size.y > particle_radius:
			particle_radius = clampf($CPUParticles2D.emission_sphere_radius + 1 * delta, particle_radius, rect.size.y)
		if gradient_offset < 0.7:
			activate_graphics(delta)
	elif done:

		if get_mobs() == false:
			explode(delta)
			
		else:
			print("still mobs")

func get_mobs():
	return true if get_overlapping_bodies().filter(func(body): return body is Mob).size() >= 1 else false

func explode(delta):
	var color := Color("White")
	gradient_offset -= 1 * delta
	var gradient : Gradient = point_light_2d.texture.gradient
	gradient.set_color(1, color)
	gradient.set_offset(1, gradient_offset)
	$CPUParticles2D.one_shot = true
	if gradient_offset <= 0 and not $CPUParticles2D.emitting:
		queue_free()


func activate_graphics(delta):
		$Untitled.hide()
		gradient_offset = clampf(gradient_offset + 1 * delta, 0, 0.7)
		var gradient : Gradient = point_light_2d.texture.gradient
		gradient.set_offset(1, gradient_offset)
		

func _on_body_entered(body):
	$CPUParticles2D.scale_amount_max = 0.5
	$CPUParticles2D.gravity = Vector2(0, -120)
	active = true



func _on_spawner_spawns_done():
	active = false
	done = true
	print("done, waiting for mobs to die")

