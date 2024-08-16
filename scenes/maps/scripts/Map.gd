@tool
extends TileMap
class_name Map

@export var current_camera_type : PlayerCamera.CameraType = PlayerCamera.CameraType.FOLLOW
@export var player_spawn : Marker2D
@export var mobs : Node2D
@export var objects : Node2D 




func _get_configuration_warnings():
	var warning : Array[String] = []
	if !is_instance_valid(player_spawn):
		player_spawn = Marker2D.new()
		player_spawn.name = "PlayerSpawn"
		add_child(player_spawn, true)
	if !is_instance_valid(mobs):
		mobs = Node2D.new()
		mobs.name = "Mobs"
		add_child(mobs, true)
	if !is_instance_valid(objects):
		objects = Node2D.new()
		objects.name = "Objects"
		add_child(objects, true)
	return warning

func _ready():
	z_index = -2

func spawn_player():
	
	PlayerManager.get_player().global_position = player_spawn.global_position
	PlayerManager.switch_camera(current_camera_type)
