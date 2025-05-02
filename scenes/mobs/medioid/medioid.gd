extends Mob




@export_category("Special Attack")
@export var buildup_time : float = 10
@export var charge_speed : float = 150
@onready var ray_cast_2d = $DetectionArea/RayCast2D
@onready var special_arrow = $DetectionArea/SpecialArrow

var current_charge_speed : float = 0
var charge_target : Vector2
var charging : bool = false


func special_attack(delta) -> MobState:
	
	if !charging:
		if current_charge_speed < charge_speed \
		and !detects_player() and ray_cast_2d.is_colliding() \
		and ray_cast_2d.get_collider() is Player:
			current_charge_speed += buildup_time * delta
			charge_target = global_position.direction_to(PlayerManager.get_global_position())
			animation.play("charge")
			velocity = Vector2.ZERO
		else:
			charging = true
	
	if charging:
		if current_charge_speed > move_speed:
			current_charge_speed -= buildup_time * 0.5 * delta
			return charge(delta)
		if current_charge_speed <= move_speed:
			print(current_charge_speed)
			charging = false
			special_timer = special_attack_cooldown
			current_charge_speed = 0
			return MobState.CHASING
	return MobState.SPECIAL

func charge(delta) -> MobState:
	animation.play("walk", -1, 3, true)
	$DetectionArea/SpecialArrow.visible = false
	velocity = current_charge_speed * charge_target
	var hit : KinematicCollision2D = move_and_collide(velocity * delta)
	if hit:
		var hit_object = hit.get_collider()
		var angle = hit.get_normal()
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(snapped(current_charge_speed * .25, 1), angle, current_charge_speed)
		else:
			take_damage(snapped(current_charge_speed * .125, 1), -angle, -current_charge_speed * .5)
		current_charge_speed = 0
		charging = false
		return MobState.CHASING
	return MobState.SPECIAL
