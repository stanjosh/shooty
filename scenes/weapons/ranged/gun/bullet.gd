extends WeaponOrdinance


@onready var gun_fire = $GunFire
@onready var shot_range = weapon_info.shot_range
var charge : float = 0

func _ready():
	
	gun_fire.play()


func _physics_process(delta):
	
	if shot_range <= 0:
		print("bullet died")
		queue_free()
	else:
		var direction = Vector2.RIGHT.rotated(rotation)
		position += direction * weapon_info.speed * delta
		shot_range -= 40 * delta

func _on_projectile_body_entered(body):

	if body.has_method("take_damage"):
		body.take_damage(weapon_info.damage, Vector2.LEFT.rotated(global_rotation))
		damage -= 1
		if body.get("bleeds"):
			BloodSpray.new(body, Vector2.LEFT.rotated(global_rotation))
	if weapon_info.piercing == 0:
		queue_free()
	else:
		weapon_info.piercing -= 1
	


