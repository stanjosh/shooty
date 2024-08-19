extends Bullet

const BURNING_EFFECT = preload("res://scenes/effects/burning_effect.tscn")

func deal_damage(body: CharacterBody2D) -> void:
	var new_burning : Infliction = BURNING_EFFECT.instantiate()
	new_burning.period = damage
	new_burning.position += Vector2(-1, -8)
	body.call_deferred("add_child", new_burning)
	return super.deal_damage(body)
