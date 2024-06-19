extends Node

signal level_up(changes)
signal give_item(item : PackedScene)

var current_xp : int = 0
var level_up_xp : int = 100
var held_items : Array[PackedScene]

func _ready():
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)

func give_xp(value):
	current_xp += value
	if current_xp >= level_up_xp:
		current_xp = 0
		level_up_xp = snapped(level_up_xp + level_up_xp * .04 , 1)
		level_up.emit()
	Hud.update_hud.emit("XPCounter", current_xp, level_up_xp)
	

func handle_give_item(item : PackedScene):
	held_items.push_back(item)
	give_item.emit(item)
