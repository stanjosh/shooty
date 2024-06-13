extends Camera2D

const SCREEN_SIZE := Vector2(416, 288)

var current_screen : Vector2

@export var following : bool = true

@onready var player = $".."
@onready var world = $"../.."

@export var default_zoom : Vector2 = Vector2(3, 3)
@export var max_zoom : Vector2 = Vector2(4.5, 4.5)
@export var zoom_timer : float = 0
var dynamic_zoom_level : Vector2


func _ready():
	get_dynamic_zoom()
	global_position = get_parent().global_position
	if not following:
		
		_update_screen( current_screen )

func switch_to_positional( current_screen ):
	following = false
	top_level = true
	global_position = get_parent().global_position
	_update_screen( current_screen )
	
func switch_to_following():
	following = true
	top_level = false
	global_position = get_parent().global_position

func _physics_process(delta):
	if not following:
		var parent_screen : Vector2 = ( get_parent().global_position / SCREEN_SIZE ).floor()
		if not parent_screen.is_equal_approx( current_screen ):
			_update_screen( parent_screen )
	else:

		if dynamic_zoom_level <= zoom:
			zoom -= Vector2(delta, delta)
		elif zoom < dynamic_zoom_level:
			zoom += get_dynamic_zoom() * Vector2(delta, delta) 


func _update_screen( new_screen : Vector2 ):
	current_screen = new_screen
	global_position = current_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5

func get_dynamic_zoom():
	var danger = clampf(( player.get_danger()  ) * .25, 0, 5)
	var new_zoom = Vector2(danger, danger)
	dynamic_zoom_level = new_zoom + default_zoom
	return new_zoom


