extends Node2D

@onready var collision_shape_2d : CollisionShape2D = $TrackingCameraArea/CollisionShape2D


@export var camera_one_type : PlayerCamera.CameraType
@export var camera_two_type : PlayerCamera.CameraType

var rect := RectangleShape2D.new()

func resize_area(size: Vector2):
	rect.extents = size - Vector2(Settings.TILE_SIZE.x * .5, Settings.TILE_SIZE.y * .5)
	collision_shape_2d.shape = rect


func _on_camera_one_area_body_exited(body):
	PlayerManager.switch_camera(camera_one_type)


func _on_camera_two_area_body_exited(body):
	PlayerManager.switch_camera(camera_two_type)



func _on_tracking_camera_area_body_entered(body):
	var top = collision_shape_2d.global_position.y - rect.extents.y - Settings.TILE_SIZE.y * .5
	var right = collision_shape_2d.global_position.x + rect.extents.x + Settings.TILE_SIZE.y * .5
	var bottom = collision_shape_2d.global_position.y + rect.extents.y + Settings.TILE_SIZE.y * .5
	var left = collision_shape_2d.global_position.x - rect.extents.x - Settings.TILE_SIZE.y * .5
	
	PlayerManager.switch_camera(PlayerCamera.CameraType.LIMIT, [top, right, bottom, left])


func _on_tracking_camera_area_body_exited(body):
	PlayerManager.switch_camera(PlayerCamera.CameraType.POSITIONAL)
