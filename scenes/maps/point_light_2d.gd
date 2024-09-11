extends PointLight2D


var offsets : PackedFloat32Array = texture.gradient.offsets 

var anim_timer = 0.1

func _process(delta: float) -> void:
	anim_timer -= delta
	if anim_timer < 0:
		anim_timer = 0.1
		offsets[0] = randf_range(0.2, 0.22)
		offsets[1] = randf_range(0.4, 0.42)
		offsets[2] = randf_range(0.5, 0.52)
		texture.fill_from.y = randf_range(0.5, 0.51)
		texture.gradient.offsets = offsets
