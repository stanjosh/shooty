extends Node2D

func _physics_process(_delta):
	pass

	
func _on_animated_sprite_2d_animation_finished():
	queue_free()
	pass # Replace with function body.
