extends WeaponOrdinance
class_name Bullet

@onready var gun_fire = $GunFire
@onready var shot_range = weapon_info.damage_range
@onready var remaining_speed = weapon_info.speed

var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	gun_fire.play()


func _physics_process(delta):
	remaining_speed -= delta
	if shot_range <= 0:
		print("bullet died")
		end_bullet()
	else:
		position += direction * remaining_speed * delta
		shot_range -= 40 * delta

func _on_projectile_body_entered(body):
	if body.has_method("take_damage"):
		deal_damage(body)


func deal_damage(body: CharacterBody2D) -> void:
	body.take_damage(weapon_info.damage, Vector2.RIGHT.rotated(rotation))
	damage -= 1
	if remaining_speed == 0:
		end_bullet()
	else:
		remaining_speed -= 2
	
func end_bullet():
	queue_free()
