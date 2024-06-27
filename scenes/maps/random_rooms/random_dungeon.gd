extends TileMap

var dungeon := {}
@onready var map_node = $MapNode
@onready var camera_2d : Camera2D = $Camera2D



var room_pattern : TileMapPattern = tile_set.get_pattern(2)
var door_pattern_y : TileMapPattern = tile_set.get_pattern(3)
var door_pattern_x : TileMapPattern = tile_set.get_pattern(4)

func _ready():
	dungeon = DungeonGeneration.generate(0)
	load_map()

func load_map():
	var room_size = Vector2i(13, 9)
	var pos_x_door_offset = Vector2i(11, 3)
	var neg_x_door_offset = Vector2i(-2, 3)
	var pos_y_door_offset = Vector2i(5, 7)
	var neg_y_door_offset = Vector2i(5, -2)
	for i in range(0, map_node.get_child_count()):
		map_node.get_child(i).queue_free()
	
	for room in dungeon.keys():
		set_pattern(0, room * room_size, room_pattern)
	for room in dungeon:
		
		var connected_rooms = dungeon[room].connected_rooms
		for connected_room in connected_rooms:
			
			if connected_rooms[connected_room] != null:

				if connected_room.x == -1:
					var door_position = (room * room_size) + neg_x_door_offset
					set_pattern(0, door_position, door_pattern_x)
				elif connected_room.x == 1:
					var door_position = (room * room_size) + pos_x_door_offset
					set_pattern(0, door_position, door_pattern_x)
				elif connected_room.y == -1:
					var door_position = (room * room_size) + neg_y_door_offset
					set_pattern(0, door_position, door_pattern_y)
				elif connected_room.y == 1:
					var door_position = (room * room_size) + pos_y_door_offset
					set_pattern(0, door_position, door_pattern_y)


func _on_button_pressed():
	clear_layer(0)
	clear()
	randomize()
	dungeon = DungeonGeneration.generate(randi_range(-1000, 1000))
	load_map()
