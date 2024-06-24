extends StaticBody2D

signal toggle_inventory(external_inventory_owner)


@export var locked : bool = false
@export var inventory_data: InventoryData
@export var key_item: ItemData
var open : bool = false

func open_chest():
	open = true
	toggle_inventory.emit(self)
	$ChestClosed.hide()
	$ChestOpen.show()

func close_chest():
	open = false
	toggle_inventory.emit(self)
	$ChestClosed.show()
	$ChestOpen.hide()

func _on_interactable_area_body_exited(body):
	if open and body is Player:
		close_chest()

func _on_interactable_area_interacted(player):
	if not open and not locked:
		open_chest()
	elif open:
		close_chest()
	else:
		var player_inventory : InventoryData = player.inventory_data
		var key = player_inventory.use_key_item(key_item)
		if key:
			Hud.float_message(["Used %s" % key_item.name], player.global_position)
			locked = false
			open_chest()
		else:
			Hud.float_message(["Need a %s" % key_item.name], player.global_position)

