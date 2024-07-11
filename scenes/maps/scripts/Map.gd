@tool
extends TileMap
class_name Map

@export var current_camera_type : PlayerCamera.CameraType = PlayerCamera.CameraType.FOLLOW
@export var player_spawn : Marker2D :
	set(value):
		player_spawn = value
		update_configuration_warnings()
@export var mobs : Node2D :
	set(value):
		mobs = value
		update_configuration_warnings()
@export var objects : Node2D :
	set(value):
		objects = value
		update_configuration_warnings()




func _get_configuration_warnings():
	var warning : Array[String] = []
	if !is_instance_valid(player_spawn):
		warning.push_back("Need a SpawnPoint : Marker2D for the player")
	if !is_instance_valid(mobs):
		warning.push_back("Need a Mobs : Node2D node")
	if !is_instance_valid(objects):
		warning.push_back("Need an Objects : Node2D node")
	return warning

func _ready():
	z_index = -2
	spawn_player()


func spawn_player():
	
	PlayerManager.get_player().global_position = player_spawn.global_position
	PlayerManager.player_camera.reset_smoothing()


