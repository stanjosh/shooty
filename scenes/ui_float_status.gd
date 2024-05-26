extends Node2D

@onready var number = $number
@onready var display_time = $display_time

var display_number : String = "0"


func _ready():
	print("displaying", " ", display_number, " ", display_time.time_left)

func _process(delta):
	if display_time.time_left > 0:
		global_position.y += delta
		visible = true
		number.text = display_number
	else:
		queue_free()
		
	
