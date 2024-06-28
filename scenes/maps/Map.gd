extends Node2D
class_name Map




var player : CharacterBody2D
@export var camera_is_following : bool = false
@export var player_spawn : Marker2D = null



func _ready():
	assert(player_spawn, "Put a spawn point on the map.")
	if player_spawn:
		player = PlayerManager.spawn_player_at(self, player_spawn.global_position)
		add_child(player)
	else:
		push_error("need a player spawn Marker2D assigned to map")
	if camera_is_following:
		PlayerManager.switch_camera(PlayerCamera.CameraType.FOLLOW)
	else:
		PlayerManager.switch_camera(PlayerCamera.CameraType.POSITIONAL)




func _on_tracking_camera_area_body_entered(body):
	pass # Replace with function body.
