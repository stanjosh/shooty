class_name PlayerCamera
extends Camera2D

var screen_size : Vector2 = Settings.SCREEN_SIZE

var current_screen : Vector2


enum CameraType {
	FOLLOW,
	POSITIONAL,
	LIMIT
}

var state : CameraType = CameraType.FOLLOW
var y_coord : float
var x_coord: float

func _ready():
	zoom = Settings.CAMERA_ZOOM
	position_smoothing_enabled = true

func switch_to_positional():
	top_level = true
	global_position = get_parent().global_position
	_update_screen( get_parent().global_position )
	
func switch_to_following():
	top_level = false
	global_position = get_parent().global_position

func switch_to_tracking():
	top_level = false
	global_position = get_parent().global_position


func switch_camera(camera_type: CameraType, limits: Array[int] = []):

	print("switch to : ", CameraType.keys()[camera_type])

	_reset_limits()
	match camera_type:
		state:
			pass
		CameraType.FOLLOW:
			state = CameraType.FOLLOW
			switch_to_following()
		CameraType.POSITIONAL:
			state = CameraType.POSITIONAL
			switch_to_positional()
		CameraType.LIMIT:
			_set_limits(limits)
			state = CameraType.LIMIT
			switch_to_tracking()
		_:
			state = CameraType.FOLLOW
			switch_to_following()

func _physics_process(delta):
	match state:
		CameraType.POSITIONAL:
			var parent_screen : Vector2 = ( get_parent().global_position / screen_size ).floor()
			if not parent_screen.is_equal_approx( current_screen ):
				_update_screen( parent_screen )
		CameraType.FOLLOW:
			pass
		CameraType.LIMIT:
			pass

func _reset_limits():
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000
	limit_left = -10000000
	limit_smoothed = true
	
func _set_limits(limits: Array[int]):
	limit_top = limits[0]
	limit_right = limits[1]
	limit_bottom = limits[2]
	limit_left = limits[3]

func _update_screen( new_screen : Vector2 ):
	current_screen = new_screen
	global_position = current_screen * screen_size + screen_size * 0.5

