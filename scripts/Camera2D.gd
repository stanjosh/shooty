extends Camera2D

@onready var player = $".."
@onready var world = $"../.."

@export var default_zoom : Vector2 = Vector2(3, 3)
@export var max_zoom : Vector2 = Vector2(4.5, 4.5)
@export var zoom_timer : float = 0
var dynamic_zoom_level : Vector2


func _ready():
	get_dynamic_zoom()
	pass
	
func get_dynamic_zoom():
	var danger = clampf(( world.danger_factor -1 ) * .25, 0, 5)
	var new_zoom = Vector2(danger, danger)
	dynamic_zoom_level = new_zoom + default_zoom
	return new_zoom

	
func _process(delta):
	if dynamic_zoom_level <= zoom:
		zoom -= Vector2(delta, delta)
	elif zoom < dynamic_zoom_level:
		zoom += get_dynamic_zoom() * Vector2(delta, delta) 

	
	
	if player.velocity.y > 0:
		drag_vertical_offset = 0.5
	elif player.velocity.y < 0:
		drag_vertical_offset = -0.5
	else:
		drag_vertical_offset = 0
	if player.velocity.x > 0:
		drag_horizontal_offset = 0.25
	elif player.velocity.x < 0:
		drag_horizontal_offset = -0.25
	else:
		drag_horizontal_offset = 0
