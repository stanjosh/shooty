extends State
class_name Idle

@export var enemy : CharacterBody2D

@export var move_speed : float
var move_direction : Vector2
@export var wander_time : float
@export var pause_time : float = randf_range(1, 3)
@export var wander_distance : float = 10

var player : CharacterBody2D

func randomize_wander():
	pause_time = randf_range(1, 3)
	move_direction = Vector2(randf_range(-wander_distance/2, wander_distance/2), randf_range(-wander_distance/2, wander_distance/2)).normalized()
	wander_time = randf_range(1, 3)
	
func Enter():
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	elif pause_time > 0:
		move_direction = Vector2(0, 0)
		pause_time -= delta
	else:
		randomize_wander()
		
func Physics_Update(delta: float):
	if enemy:
		enemy.velocity = move_direction * move_speed
		
