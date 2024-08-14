extends Mob




@export_category("Special Attack")
var copies_left: int =  2

func special_attack(delta) -> MobState:
	special_timer = special_attack_cooldown
	return MobState.CHASING

func take_damage(hit, vector: Vector2, extra_force: float = 0):
	if copies_left:
		var new_copy := self.duplicate()
		new_copy.strategy = MobStrategy.CHASE
		new_copy.original_pos = original_pos
		new_copy.copies_left = copies_left - 1
		new_copy.scale = scale * 0.75
		new_copy.global_position = global_position + Vector2(randi_range(-2, 2), randi_range(-2, 2))
		new_copy.chase_timer = chase_time
		get_parent().call_deferred("add_child", new_copy)
	return super.take_damage(hit, vector, extra_force)
