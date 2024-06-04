extends Node

@onready var pause_menu = $hud/PauseMenu


var paused : bool = false

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause()



func pause():
	
	if paused:
		pause_menu.hide()
		$World.process_mode = Node.PROCESS_MODE_ALWAYS

	else:
		pause_menu.show()
		$World.process_mode = Node.PROCESS_MODE_DISABLED
	paused = !paused



func _on_resume_pressed():
	pause()




func _on_quit_pressed():
	get_tree().quit()

