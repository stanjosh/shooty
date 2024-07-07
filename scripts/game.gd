extends Node

@onready var world = %World

var paused: bool = true

func _ready():
	UiManager.connect("pause_game", pause)

func pause():
	
	if paused:
		%World.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		%World.process_mode = Node.PROCESS_MODE_DISABLED
	paused = !paused
