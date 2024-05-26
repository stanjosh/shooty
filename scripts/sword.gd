extends Node2D

var target_enemy : CharacterBody2D

func _physics_process(delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		if enemies_in_range.front() != target_enemy:
			target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
