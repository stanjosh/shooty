extends Node

const PLAYER = preload("res://scenes/player/player.tscn")
@onready var game = get_node("/root/Game")
signal level_up(changes)
signal give_item(item : PackedScene)
signal player_died

var current_xp : int = 0
var level_up_xp : int = 100
var held_items : Array[PackedScene]

var player : Player
var player_camera : PlayerCamera


func _ready():
	GUI.hud.update("xp", current_xp, level_up_xp)

func use_slot_data(slot_data : SlotData):
	slot_data.item_data.use(player)

func give_xp(value: int):
	current_xp += value
	if current_xp >= level_up_xp:
		current_xp = 0
		level_up_xp = snapped(level_up_xp + level_up_xp * .04 , 1)
		level_up.emit()
	GUI.hud.update("xp", current_xp, level_up_xp)
	

func get_player(position: Vector2 = Vector2.ZERO) -> Player:
	if not player:
		player = PLAYER.instantiate()
		player_camera = PlayerCamera.new()
		player.add_child(player_camera)
		game.add_child(player)
		player.position = position
	return player

func spawn_player():
	get_player(MapManager.current_map.player_spawn.global_position)

func switch_camera(camera_type: PlayerCamera.CameraType, limits: Array[int] = []):
	player_camera.switch_camera(camera_type, limits)
	
func _on_player_died():
	GUI.game_over.emit()

func get_global_position() -> Vector2:
	return player.global_position
