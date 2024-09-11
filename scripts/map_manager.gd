extends Node


const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")
@export var start_map : String = "hub"
var current_map : Map
var default_map = "hub"

@export var maps : Dictionary = {
	"hub" : preload("res://scenes/maps/SurvivalMap.tscn")
} 


var saved_scenes := {}



func load_map(map_name: String = default_map):
	var new_map = maps[map_name].instantiate()
	if current_map:
		current_map.queue_free()
	current_map = new_map
	add_child(new_map)
	PlayerManager.get_player(current_map, current_map.player_spawn.global_position)

func save_map(_map_name, _root_node):
	pass
	
func drop_item(loot : ItemData, global_position : Vector2) -> void:
		if loot:
			var new_item = loot.pick_random()
			var pick_up = PICKUP_ITEM.instantiate()
			pick_up.slot_data = SlotData.new()
			pick_up.slot_data.item_data = new_item
			pick_up.position = global_position
			current_map.call_deferred("add_child", pick_up)

func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PICKUP_ITEM.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = current_map.get_global_mouse_position()
	current_map.add_child(pick_up)
