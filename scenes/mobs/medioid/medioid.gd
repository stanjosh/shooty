extends Mob




@export_category("Special Attack")
@export var charge_time : float = 2
@export var charge_speed : float = 150
@onready var ray_cast_2d = $DetectionArea/RayCast2D



var current_charge_speed : float = 0
var charge_target : Vector2
var charge_timer : float = charge_time

func _physics_process(delta):
	
	if state == MobState.CHASING:
		current_charge_speed = 0
		if attack_cooldown <= 0:
			if !detection_area.overlaps_body(PlayerManager.player) and ray_cast_2d.is_colliding():
				if ray_cast_2d.get_collider() is Player:
					attack_cooldown = cooldown
					charge_target = global_position.direction_to(PlayerManager.get_global_position())
					state = MobState.SPECIAL
					current_charge_speed = 0
					charge_timer = charge_time
					velocity = Vector2.ZERO
					hurtbox_anim.play("charge")
					var tween = get_tree().create_tween()
					tween.tween_property(self, "current_charge_speed", charge_speed, charge_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	elif state == MobState.SPECIAL and charge_timer > 0:
		charge_timer -= 1 * delta
		
		if charge(delta):
			charge_timer = 0
		if charge_timer <= 0:
			state = MobState.CHASING
	
	return super._physics_process(delta)

func charge(delta) -> bool:
	
	velocity = current_charge_speed * charge_target
	var hit : KinematicCollision2D = move_and_collide(velocity * delta)
	if hit:
		velocity = Vector2.ZERO
		var hit_object = hit.get_collider()
		if hit_object:
			var angle = (hit_object.global_position * hit.get_angle()).normalized()
			
			if hit_object.has_method("take_damage"):
				hit_object.take_damage(current_charge_speed * .25, angle, current_charge_speed * .5 )
			else:
				take_damage(current_charge_speed * .25, angle, current_charge_speed * .5)
			
		return true
	return false

