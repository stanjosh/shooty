extends ProgressBar

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = player.health
	value = player.health
	min_value = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = player.health
	visible = false if player.health == 100 else true
	pass
