extends Area2D


const POISON_EFFECT = preload("res://scenes/effects/poison_effect.tscn")
@export var cooldown = 3
func _physics_process(delta):
	cooldown -= 1 * delta
	if overlaps_body(PlayerManager.player):
		if cooldown <= 0:
			cooldown = 3
			var new_poison = POISON_EFFECT.instantiate()
			new_poison.position += Vector2(-1, -8)
			PlayerManager.player.add_child(new_poison)
