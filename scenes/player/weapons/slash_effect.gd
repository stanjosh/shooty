extends Line2D



func _process(delta):
	if modulate.a > 0:
		modulate.a -= 5 * delta
	else:
		queue_free()
