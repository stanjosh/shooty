extends Node2D

@onready var collision_shape_2d : CollisionShape2D = $TrackingCameraArea/CollisionShape2D

var rect := RectangleShape2D.new()

func resize_area(size: Vector2):
	rect.extents = size - Vector2(Settings.TILE_SIZE.x * .5, Settings.TILE_SIZE.y * .5)
	collision_shape_2d.set_deferred("shape", rect)


func _on_tracking_camera_area_body_entered(body):
	if body is Player:
		var top = int(collision_shape_2d.global_position.y - rect.extents.y - Settings.TILE_SIZE.y * .5)
		var right = int(collision_shape_2d.global_position.x + rect.extents.x + Settings.TILE_SIZE.y * .5)
		var bottom = int(collision_shape_2d.global_position.y + rect.extents.y + Settings.TILE_SIZE.y * .5)
		var left = int(collision_shape_2d.global_position.x - rect.extents.x - Settings.TILE_SIZE.y * .5)
		
		PlayerManager.switch_camera(PlayerCamera.CameraType.LIMIT, [top, right, bottom, left])


func _on_tracking_camera_area_body_exited(body):
	if body is Player:
		PlayerManager.switch_camera(PlayerCamera.CameraType.POSITIONAL)
