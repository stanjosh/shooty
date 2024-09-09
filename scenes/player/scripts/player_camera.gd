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

@export var shake_noise : FastNoiseLite = FastNoiseLite.new()
var noise_index : float = 0.0
@export var shake_speed : float = 100.0
@export var shake_strength : float = 10.0
@export var shake_decay : float = 3.0
@export var shake_angle : Vector2 = Vector2(0,0)

func get_shake_offset(delta : float) -> Vector2:
	noise_index += delta * shake_speed
	shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	#var random_offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	return Vector2(
		shake_noise.get_noise_2d(1, noise_index) * shake_strength,
		shake_noise.get_noise_2d(100, noise_index) * shake_strength
	) + shake_angle * shake_strength
	
func shake(speed : float = shake_speed, strength : float = shake_strength, decay : float = shake_decay, angle : Vector2 = Vector2(0,0)):
	shake_speed = speed
	shake_strength = strength
	shake_decay = decay
	shake_angle = angle

func _ready():
	shake_noise.noise_type = FastNoiseLite.TYPE_VALUE
	shake_noise.frequency = 1.2
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

func _process(delta):
	match state:
		CameraType.POSITIONAL:
			var parent_screen : Vector2 = ( get_parent().global_position / screen_size ).floor()
			if not parent_screen.is_equal_approx( current_screen ):
				_update_screen( parent_screen )
		CameraType.FOLLOW:
			pass
		CameraType.LIMIT:
			pass
	offset = get_shake_offset(delta)

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
