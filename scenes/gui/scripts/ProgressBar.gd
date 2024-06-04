extends ProgressBar

@onready var player = $".."
@onready var gun = $"../gun"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gun.reload_timer.time_left:
		visible = true
		value = 1 - ( gun.reload_timer.time_left / gun.reload_timer.wait_time )
	else: 
		visible = false
