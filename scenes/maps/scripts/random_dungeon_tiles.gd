extends TileMap
class_name RandomDungeonTiles

const ROOM_MOBS = preload("res://scenes/maps/spawner/room_mobs.tscn")
const DUNGEON_TRACKING_CAMERA_SWITCHER = preload("res://scenes/interactable/dungeon_tracking_camera_switcher.tscn")
const DOOR = preload("res://scenes/interactable/door.tscn")
var room_size = Settings.ROOM_SIZE
@onready var player_spawn = %PlayerSpawn

var room_pattern : TileMapPattern = tile_set.get_pattern(0)
var door_pattern_x : TileMapPattern = tile_set.get_pattern(5)
var door_pattern_y : TileMapPattern = tile_set.get_pattern(4)
var door_cieling_x : TileMapPattern = tile_set.get_pattern(7)
var door_cieling_y : TileMapPattern = tile_set.get_pattern(6)
var door_frame_x : TileMapPattern = tile_set.get_pattern(8)
var door_frame_y : TileMapPattern = tile_set.get_pattern(9)
var entrance_pattern : TileMapPattern = tile_set.get_pattern(3)
var big_room_conn_x = tile_set.get_pattern(2)
var big_room_conn_y = tile_set.get_pattern(1)
var big_room_conn_offset_x = Vector2i(11, 0)
var big_room_conn_offset_y = Vector2i(0, 7)
var x_door_offset = Vector2i(11, 3)
var y_door_offset = Vector2i(5, 7)

var dungeon := {}
var new_seed : int = randi_range(-10000, 10000)

func _ready():
	dungeon = DungeonGeneration.generate(new_seed)
	load_map()

func load_map():
	for child in get_children():
		child.queue_free()
	for room in dungeon.keys():
		set_pattern(0, room * room_size, room_pattern)
	if not draw_entrance():
		load_map()
	for room in dungeon.values():
		draw_doors(room)
		create_mob_area(room)


func maybe_connect_rooms(room, connected_room) -> bool:
	if randi()%100 < 25 \
		and not connected_room.big_room\
		and not room.big_room:
		if room.position.x != connected_room.position.x:
			set_pattern(0, (room.position * room_size) + big_room_conn_offset_x, big_room_conn_x)
			set_pattern(0, (connected_room.position * room_size), big_room_conn_x)
		elif room.position.y != connected_room.position.y:
			set_pattern(0, (room.position * room_size) + big_room_conn_offset_y, big_room_conn_y)
			set_pattern(0, (connected_room.position * room_size), big_room_conn_y)
		create_camera_area(room, connected_room)
		room.big_room = true
		connected_room.big_room = true
		return true
	return false

func maybe_lock_door(door_position, door_rotation = 0) -> bool:
	if randi() % 100 < 20:
		var door = DOOR.instantiate()
		var offset = Vector2i(0, 3) if door_rotation else Vector2i(0, 0)
		door.global_position = Vector2(door_position + offset)  * Settings.TILE_SIZE
		door.rotation_degrees = door_rotation
		add_child(door)
		return true
	return false

func create_camera_area(room, connected_room) -> void:
	var tracking_area = DUNGEON_TRACKING_CAMERA_SWITCHER.instantiate()
	if room.position.x == connected_room.position.x:
		tracking_area.global_position.x = ((room_size.x * room.position.x + room_size.x / 2) * tile_set.tile_size.x) + tile_set.tile_size.x / 2
		tracking_area.global_position.y = (room_size.y * connected_room.position.y * tile_set.tile_size.y)
		add_child(tracking_area)
		tracking_area.resize_area( Vector2i(room_size.x, room_size.y * 2) * (tile_set.tile_size) / 2)
	if room.position.y == connected_room.position.y:
		tracking_area.global_position.y = ((room_size.y * room.position.y + room_size.y / 2) * tile_set.tile_size.y) + tile_set.tile_size.y / 2
		tracking_area.global_position.x = (room_size.x * connected_room.position.x * tile_set.tile_size.x)
		add_child(tracking_area)
		tracking_area.resize_area( Vector2i(room_size.x * 2, room_size.y) * (tile_set.tile_size) / 2)

func create_mob_area(room) -> void:
	var mob_room = ROOM_MOBS.instantiate()
	add_child(mob_room)
	mob_room.global_position.x = ((room_size.x * room.position.x + room_size.x / 2) * tile_set.tile_size.x) + tile_set.tile_size.x / 2
	mob_room.global_position.y = ((room_size.y * room.position.y + room_size.y / 2) * tile_set.tile_size.y) + tile_set.tile_size.y / 2	
	mob_room.spawn_room()
	
func draw_doors(room) -> void:
	var random_offset = randi_range(-2, 2) if randi_range(0, 100) < 20 else 0
	for connection in room.connected_rooms:
		if connection != null and dungeon.has(room.position + connection):
			if connection.x == 1:
				var door_position = (room.position * room_size) + x_door_offset + Vector2i(0, random_offset)
				set_pattern(0, door_position, door_pattern_x)
				if not maybe_connect_rooms(room, room.connected_rooms[connection]):
					set_pattern(2, door_position, door_cieling_x)
					set_pattern(1, door_position, door_frame_x)
					if room.connected_rooms[connection].connected_rooms.size() == 1:
						if maybe_lock_door(door_position, -90):
							room.connected_rooms[connection].locked = true
			elif connection.y == 1:
				var door_position = (room.position * room_size) + y_door_offset + Vector2i(random_offset, 0)
				set_pattern(0, door_position, door_pattern_y)
				if not maybe_connect_rooms(room, room.connected_rooms[connection]):
					set_pattern(2, door_position, door_cieling_y)
					set_pattern(1, door_position, door_frame_y)
					if room.connected_rooms[connection].connected_rooms.size() == 1:
						if maybe_lock_door(door_position):
							room.connected_rooms[connection].locked = true

func draw_entrance() -> bool:
	var start_candidates = dungeon.values().filter(_start_filter)
	var start_room : Vector2i = dungeon.find_key(start_candidates.pick_random())
	if start_room:
		var door_position = (start_room * room_size) + Vector2i(5, 7)
		set_pattern(2, door_position, door_cieling_y)
		set_pattern(1, door_position, door_frame_y)
		set_pattern(0, (start_room * room_size) + Vector2i(0, 7), entrance_pattern)
		player_spawn.global_position.x = ((room_size.x * start_room.x + y_door_offset.x + 1) * tile_set.tile_size.x) + 16
		player_spawn.global_position.y = ((room_size.y * start_room.y + y_door_offset.y + 6) * tile_set.tile_size.y) + 16
		var door = DOOR.instantiate()
		door.global_position = Vector2(door_position) * Settings.TILE_SIZE 
		add_child(door)
		return true
	return false

func _start_filter(i): 
	if i.connected_rooms.size() < 4\
	and !i.connected_rooms.has(Vector2i(0, 1))\
	and !dungeon.has(i.position + Vector2i(0, 1)):
		return i


func _on_button_pressed() -> void:
	clear_layer(0)
	clear()
	randomize()
	dungeon = DungeonGeneration.generate(randi_range(-1000, 1000))
	load_map()
