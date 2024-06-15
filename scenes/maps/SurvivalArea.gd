extends Area2D
@onready var point_light_2d = $PointLight2D

var gradient_offset = 0
var active = false
var done = false

func _physics_process(delta):
	if active:
		if gradient_offset < 0.6:
			change_gradient(delta)
	elif done:
		var mobs = get_overlapping_bodies().filter(func(body): return body is Mob)
		print("still mobs")
		if not mobs:
			explode(delta)
		
func explode(delta):
	var color := Color("White")
	gradient_offset -= 1 * delta
	var gradient : Gradient = point_light_2d.texture.gradient
	gradient.set_color(1, color)
	gradient.set_offset(1, gradient_offset)


func change_gradient(delta):
		gradient_offset += 1 * delta
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

