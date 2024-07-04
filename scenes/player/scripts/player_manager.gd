extends Node

const PLAYER = preload("res://scenes/player/player.tscn")

signal game_over

signal level_up(changes)
signal give_item(item : PackedScene)


var current_xp : int = 0
var level_up_xp : int = 100
var held_items : Array[PackedScene]

var player : Player = PLAYER.instantiate()
var player_camera : PlayerCamera

func _ready():
	Hud.update_hud.emit(Hud.Element.XP, current_xp, level_up_xp)

func use_slot_data(slot_data : SlotData):
	slot_data.item_data.use(player)

func give_xp(value):
	current_xp += value
	if current_xp >= level_up_xp:
		current_xp = 0
		level_up_xp = snapped(level_up_xp + level_up_xp * .04 , 1)
		level_up.emit()
	Hud.update_hud.emit(Hud.Element.XP, current_xp, level_up_xp)
	



func spawn_player(position: Vector2, map: Map) -> Player:
	print("spawning player")
	player_camera = PlayerCamera.new()
	var new_player = PLAYER.instantiate()
	new_player.player_died.connect(_on_player_died)
	new_player.global_position = position
	player.queue_free()
	player = new_player
	map.call_deferred("add_child", player)
	player.call_deferred("add_child", player_camera)
	player_camera.call_deferred("switch_camera", map.current_camera_type)
	return player

func switch_camera(camera_type: PlayerCamera.CameraType, limits: Array[int] = []):
	player_camera.switch_camera(camera_type, limits)
	
func _on_player_died():
	
	game_over.emit()

func get_global_position() -> Vector2:
	return player.global_position
