extends ProgressBar

@onready var player = $".."
@onready var gun = $"../gun"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gun.current_state.reload.time_left:
		position = player.global_position
		visible = true
		value = ( gun.current_state.reload.time_left / gun.current_state.reload.wait_time )
	else: 
		visible = false
