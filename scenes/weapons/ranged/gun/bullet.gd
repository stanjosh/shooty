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
	apply_effects(body)
	apply_inflictions(body)
	if remaining_speed == 0:
		end_bullet()
	else:
		remaining_speed -= 2
	
func end_bullet():
	queue_free()

func apply_effects(body: CharacterBody2D) -> void:
	if weapon_info.speed > 100 and body.get("bleeds"):
		BloodSpray.new(Vector2.from_angle(global_rotation))

func apply_inflictions(body: CharacterBody2D) -> void:
	print("applying inflictions")
	var new_infliction : Infliction = weapon_info.infliction_scene.instantiate()
	new_infliction.period = (damage * .04)
	new_infliction.position += Vector2(-1, -8)
	body.call_deferred("add_child", new_infliction)
