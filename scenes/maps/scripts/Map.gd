extends Node2D
class_name Map




var player : CharacterBody2D
@export var current_camera_type : PlayerCamera.CameraType = PlayerCamera.CameraType.FOLLOW
@onready var player_spawn : Marker2D = $PlayerSpawn


func _ready():
	spawn_player()


func spawn_player():
	if player_spawn:
		player = PlayerManager.spawn_player(player_spawn.global_position, self)
	else:
		push_error("need a player spawn Marker2D assigned to map")
		assert(player_spawn, "Put a spawn point on the map.")


