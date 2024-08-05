extends WeaponRanged
class_name WeaponRangedProjectile

var shot_time : float = 0

func shoot():
	if shot_time <= 0:
		shot_time = fire_rate
		print("shoot")
		for n in pellets:
			var new_bullet = weapon_info.weapon_effect.instantiate()
			heat_level += weapon_info.heat_generated
			new_bullet.global_position = to_global(projectile_origin.position)
			new_bullet.global_rotation_degrees = global_rotation_degrees + randfn(0, area / 100)
			projectile_origin.add_child(new_bullet)
			if n == 0:
				shot_time = 100

	return super.shoot()
	
func _physics_process(delta):
	shot_time -=  delta * 100 + fire_rate
	return super._physics_process(delta)
