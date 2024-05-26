extends State
class_name Chase

@onready var enemy : CharacterBody2D = $".."
var move_direction : Vector2

var player : CharacterBody2D

func find_player():
	move_direction = global_position.direction_to(player.global_position)
func Enter():
	pass

func Update(delta: float):
	find_player()

func Physics_Update(delta: float):
	if enemy:
		enemy.velocity = move_direction * enemy.move_speed
		
