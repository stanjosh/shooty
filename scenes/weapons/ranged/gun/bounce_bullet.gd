extends Bullet
class_name BounceBullet

var already_hit : int

func deal_damage(body) -> void:
	$GPUParticles2D.emitting = true
	direction = direction.bounce(Vector2.UP)
	var potential_targets = $Area2D.get_overlapping_bodies().filter(func(_body): return _body is Mob and !_body == body)
	if potential_targets:
		direction = Vector2(potential_targets.pick_random().global_position - global_position).normalized()
	already_hit +=1
	shot_range *= 0.9
	remaining_speed *= 0.9
	scale *= 0.9
	return super.deal_damage(body)

func end_bullet():
	$GPUParticles2D.emitting = true
	if already_hit > 1:
		GUI.float_message(["%s hits!" % already_hit], PlayerManager.player)
	return super.end_bullet()
