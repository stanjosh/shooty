extends Control

@onready var game : Node = get_node("/root/Game")



func _on_resume_pressed():
	game.pause()


func _on_quit_pressed():
	get_tree().quit()
