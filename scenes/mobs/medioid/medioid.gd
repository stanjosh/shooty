extends Mob




@export_category("Special Attack")
@export var buildup_time : float = 5
@export var charge_speed : float = 1350
@onready var ray_cast_2d = $DetectionArea/RayCast2D
@onready var special_arrow = $DetectionArea/SpecialArrow

var current_charge_speed : float = 0
var charge_target : Vector2
var charging : bool = false


func special_attack(delta) -> MobState:

	if charging:
		if current_charge_speed <= 0:
			
			charging = false
			special_arrow.visible = false
			return MobState.CHASING
		return charge(delta)
	if !charging and current_charge_speed < charge_speed:
		special_arrow.look_at(PlayerManager.get_global_position())
		charge_target = global_position.direction_to(PlayerManager.get_global_position()) * 2
		animation.play("charge")
		sprite_2d.flip_h = true if charge_target.x < global_position.x else false
		velocity = -charge_target * 20
		current_charge_speed += buildup_time * delta
		if current_charge_speed > charge_speed:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "current_charge_speed", 0, 1).set_ease(Tween.EASE_IN)
			special_arrow.visible = false
			charging = true
	return MobState.SPECIAL

func charge(delta) -> MobState:
	special_timer = special_attack_cooldown
	animation.play("walk", -1, 3.0)
	velocity = current_charge_speed * charge_target
	var hit : KinematicCollision2D = move_and_collide(velocity * delta)
	if hit:
		var hit_object = hit.get_collider()
		if hit_object:
			var angle = hit.get_normal()
			if hit_object.has_method("take_damage"):
				hit_object.take_damage(snapped(current_charge_speed * .25, 1), angle, -current_charge_speed * 10)
			else:
				take_damage(snapped(current_charge_speed * .25, 1), angle)
		current_charge_speed = 0
		charging = false
		
		return MobState.CHASING
	return MobState.SPECIAL
