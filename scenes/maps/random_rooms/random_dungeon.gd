extends TileMap

var dungeon := {}
@onready var map_node = $MapNode
@onready var player_spawn = %PlayerSpawn
const DUNGEON_TRACKING_CAMERA_SWITCHER = preload("res://scenes/interactable/dungeon_tracking_camera_switcher.tscn")

var room_size = Vector2i(13, 9)

var room_pattern : TileMapPattern = tile_set.get_pattern(2)
var door_pattern_x : TileMapPattern = tile_set.get_pattern(4)
var door_pattern_y : TileMapPattern = tile_set.get_pattern(3)
var door_cieling_x : TileMapPattern = tile_set.get_pattern(0)
var door_cieling_y : TileMapPattern = tile_set.get_pattern(6)
var entrance_pattern : TileMapPattern = tile_set.get_pattern(8)
var big_room_conn_x = tile_set.get_pattern(7)
var big_room_conn_y = tile_set.get_pattern(5)
var big_room_conn_offset_x = Vector2i(11, 0)
var big_room_conn_offset_y = Vector2i(0, 7)
var x_door_offset = Vector2i(11, 3)
var y_door_offset = Vector2i(5, 7)


var big_rooms : Array

func _ready():
	dungeon = DungeonGeneration.generate(0)
	load_map()

func load_map():
	for child in map_node.get_children():
		child.queue_free()
	for room in dungeon.keys():
		set_pattern(0, room * room_size, room_pattern)
	for room in dungeon.values():
		draw_doors(room)
	if not draw_entrance(dungeon):
		load_map()


func connect_big_rooms(room, connected_room) -> bool:
	if randi()%100 < 50 \
		and not connected_room.big_room\
		and not room.big_room:
		if room.position.x < connected_room.position.x:
			set_pattern(0, (room.position * room_size) + big_room_conn_offset_x, big_room_conn_x)
			set_pattern(0, (connected_room.position * room_size), big_room_conn_x)
		if room.position.y < connected_room.position.y:
			set_pattern(0, (room.position * room_size) + big_room_conn_offset_y, big_room_conn_y)
			set_pattern(0, (connected_room.position * room_size), big_room_conn_y)
		create_camera_area(room, connected_room)
		room.big_room = true
		connected_room.big_room = true
		return true
	return false


func create_camera_area(room, connected_room) -> void:
	var tracking_area = DUNGEON_TRACKING_CAMERA_SWITCHER.instantiate()
	if room.position.x == connected_room.position.x:
		tracking_area.global_position.x = ((room_size.x * room.position.x + room_size.x / 2) * tile_set.tile_size.x) + tile_set.tile_size.x / 2
		tracking_area.global_position.y = (room_size.y * connected_room.position.y * tile_set.tile_size.y)
		map_node.add_child(tracking_area)
		tracking_area.resize_area( Vector2i(room_size.x, room_size.y * 2) * (tile_set.tile_size) / 2)
	if room.position.y == connected_room.position.y:
		tracking_area.global_position.y = ((room_size.y * room.position.y + room_size.y / 2) * tile_set.tile_size.y) + tile_set.tile_size.y / 2
		tracking_area.global_position.x = (room_size.x * connected_room.position.x * tile_set.tile_size.x)
		map_node.add_child(tracking_area)
		tracking_area.resize_area( Vector2i(room_size.x * 2, room_size.y) * (tile_set.tile_size) / 2)

func draw_doors(room) -> void:
	for connection in room.connected_rooms:
		if connection != null and dungeon.has(room.position + connection):
			if connection.x == 1:
				var door_position = (room.position * room_size) + x_door_offset
				set_pattern(0, door_position, door_pattern_x)
				if not connect_big_rooms(room, room.connected_rooms[connection]):
					set_pattern(1, door_position, door_cieling_x)
			if connection.y == 1:
				var door_position = (room.position * room_size) + y_door_offset
				set_pattern(0, door_position, door_pattern_y)
				if not connect_big_rooms(room, room.connected_rooms[connection]):
					set_pattern(1, door_position, door_cieling_y)

func draw_entrance(dungeon) -> bool:
	var start_candidates = dungeon.values().filter(func(i): 
		if i.connected_rooms.size() < 4\
		and !i.connected_rooms.has(Vector2i(0, 1))\
		and !dungeon.has(i.position + Vector2i(0, 1)):
			return i
	)
	var start_room : Vector2i = dungeon.find_key(start_candidates.pick_random())
	if start_room:
		var door_position = (start_room * room_size) + Vector2i(5, 7)
		set_pattern(1, door_position, door_cieling_y)
		set_pattern(0, (start_room * room_size) + Vector2i(0, 7), entrance_pattern)
		player_spawn.global_position.x = ((room_size.x * start_room.x + y_door_offset.x + 1) * tile_set.tile_size.x) + 16
		player_spawn.global_position.y = ((room_size.y * start_room.y + y_door_offset.y + 6) * tile_set.tile_size.y) + 16
		return true
	return false




func _input(event):
	if Input.is_action_just_released("scrollup"):
		PlayerManager.player.player_camera.zoom -= Vector2(.1, .1)
	if Input.is_action_just_released("scrolldown"):
		PlayerManager.player.player_camera.zoom += Vector2(.1, .1)

func _on_button_pressed() -> void:
	clear_layer(0)
	clear()
	randomize()
	dungeon = DungeonGeneration.generate(randi_range(-1000, 1000))
	load_map()
