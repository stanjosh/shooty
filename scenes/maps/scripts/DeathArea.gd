extends Area2D


func _physics_process(delta):
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.has_method("die"):
				body.die()
