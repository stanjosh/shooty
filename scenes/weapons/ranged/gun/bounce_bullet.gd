extends Bullet
class_name BounceBullet

var already_hit : int

func _on_projectile_body_entered(body):
	direction = direction.bounce(Vector2.UP) 
	already_hit +=1
	shot_range += 5
	return super._on_projectile_body_entered(body)

func end_bullet():
	GUI.float_message(["%s hits!" % already_hit], self)
	return super.end_bullet()
