extends Bullet
class_name BounceBullet

var already_hit : Array[Mob]


func deal_damage(body) -> void:
	$GPUParticles2D.emitting = true
	direction = direction.bounce(Vector2.UP)
	var potential_targets = $Area2D.get_overlapping_bodies().filter(determine_target)
	if potential_targets:
		var target = potential_targets.pick_random()
		direction = Vector2(target.global_position - global_position).normalized()
	shot_range *= 0.9
	remaining_speed *= 0.9
	scale *= 0.9
	return super.deal_damage(body)

func determine_target(_body):
	if _body in already_hit:
		return false
	return _body is Mob

func end_bullet():
	$GPUParticles2D.emitting = true
	if already_hit.size() > 1:
		GUI.float_message(["%s hits!" % already_hit], PlayerManager.player)
	return super.end_bullet()
