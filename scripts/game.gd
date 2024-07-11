extends Node


var paused: bool = false

func pause():
	
	if paused:
		MapManager.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		MapManager.process_mode = Node.PROCESS_MODE_DISABLED
	paused = !paused

func _ready():
	UIManager.connect("pause_game", pause)


