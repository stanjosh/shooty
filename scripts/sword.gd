extends Area2D


func _physics_process(delta):
	global_rotation = global_position.angle_to_point(get_global_mouse_position())
