extends Node2D


func get_mobs() -> Array[CharacterBody2D]:
	return get_children().filter(func(child): return child is Mob)

const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")

func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PICKUP_ITEM.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = get_global_mouse_position()
	add_child(pick_up)
