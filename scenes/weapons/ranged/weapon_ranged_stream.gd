extends WeaponRanged
class_name WeaponRangedStream

@onready var ordinance : StreamOrdinance = weapon_info.weapon_effect.instantiate()

func _ready() -> void:
	projectile_origin.add_child(ordinance)
	return super._ready()

func _physics_process(delta) -> void:
	
	heat_level += weapon_info.heat_generated * delta
	if Input.is_action_just_released("shoot"):
		ordinance.emitting = false
	return super._physics_process(delta)

func shoot():
	ordinance.emitting = true
	return super.shoot()
