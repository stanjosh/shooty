extends Node

class DungeonRoom:
	var connected_rooms := {}
	var number_of_connections = 0
	var position : Vector2i
	var big_room: bool = false
	var locked: bool = false

var min_rooms = 6
var max_rooms = 18
var generation_chance = 30



var directions = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

func generate(room_seed):
	seed(room_seed)
	var dungeon := {}
	var size = randi_range(min_rooms, max_rooms)
	
	dungeon[Vector2i(0, 0)] = DungeonRoom.new()
	
	size -= 1
	var start_room = dungeon.find_key(Vector2i(0, 0))

	
	while(size > 0):
		for room_position in dungeon.keys():
			if randi_range(0, 100) < generation_chance:
				var direction = directions.pick_random()
				var new_room_position = room_position + direction
				if not dungeon.has(new_room_position):
					dungeon[new_room_position] = DungeonRoom.new()
					dungeon[new_room_position].position = new_room_position
					size -= 1
					if !dungeon[room_position].connected_rooms.has(dungeon[new_room_position])\
						and dungeon[room_position] != start_room:
						connect_rooms(dungeon[room_position], dungeon[new_room_position], direction)
	while(!is_interesting(dungeon)):
		dungeon = generate(randi())
	return dungeon
		


func connect_rooms(room1 : DungeonRoom, room2: DungeonRoom, direction):
	
	room1.connected_rooms[direction] = room2
	room2.connected_rooms[-direction] = room1
	room1.number_of_connections += 1
	room2.number_of_connections += 1

func is_interesting(dungeon):
	var room_with_three = 0
	for i in dungeon.keys():
		if(dungeon.get(i).number_of_connections >= 3):
			room_with_three += 1
	return room_with_three >= 2

