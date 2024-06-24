extends Node


const PLAYER = preload("res://scenes/player/player.tscn")

signal level_up(changes)
signal give_item(item : PackedScene)

var current_xp : int = 0
var level_up_xp : int = 100
var held_items : Array[PackedScene]

var player : Player = PLAYER.instantiate()

func _ready():
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)

func use_slot_data(slot_data : SlotData):
	slot_data.item_data.use(player)

func give_xp(value):
	current_xp += value
	if current_xp >= level_up_xp:
		current_xp = 0
		level_up_xp = snapped(level_up_xp + level_up_xp * .04 , 1)
		level_up.emit()
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)
	

func spawn_player_at(global_position) -> Player:
	player.position = global_position
	return player



func get_global_position() -> Vector2:
	return player.global_position
