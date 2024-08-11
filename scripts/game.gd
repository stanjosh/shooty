extends Node


var paused: bool = false

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	
	if paused:
		MapManager.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		MapManager.process_mode = Node.PROCESS_MODE_DISABLED
	paused = !paused
