extends Node2D

func _physics_process(_delta):
	if get_parent().has_method("take_damage"):
		var stream = $AudioStreamPlayer2D.stream
		SoundManager.register_sound(stream)
		if !SoundManager.sound_was_recently_played(stream):
			$AudioStreamPlayer2D.play()
	
func _on_animated_sprite_2d_animation_finished():
	queue_free()
	pass # Replace with function body.
