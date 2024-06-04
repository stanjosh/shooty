extends Control

@onready var game : Node = $".."

func _ready():
	print("what the fuck")
	print(game.name)

func _on_resume_pressed():
	print("what the fuck")
	game.pause()


func _on_quit_pressed():
	get_tree().quit()
