extends Control
class_name GameOver

@onready var restart_button = $MarginContainer/VBoxContainer/RestartButton

func _ready():
	restart_button.grab_focus()
