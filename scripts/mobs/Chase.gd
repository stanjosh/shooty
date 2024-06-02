extends State
class_name Chase

@onready var enemy : CharacterBody2D = $".."
var move_direction : Vector2

var target

func find_target():

	
func Enter():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):

	if target and enemy:
		find_target()
		
		
