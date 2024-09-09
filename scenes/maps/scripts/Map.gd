class_name Map extends TileMapLayer


@export var player_spawn : Marker2D :
	set(value):
		if value is Marker2D:
			player_spawn = value
		elif value == null:
			player_spawn = Marker2D.new()
