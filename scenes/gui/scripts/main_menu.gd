extends Control
class_name MainMenu

var fullscreen : bool = false
@onready var play = $MarginContainer/VBoxContainer/NinePatchRect2/play

func _ready():
	play.grab_focus()

func _on_options_pressed():
	fullscreen = !fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()


	
