extends StaticBody2D
class_name Chest

signal toggle_inventory(external_inventory_owner)
signal interactable_area_exited()
@onready var interface_anchor = $InterfaceAnchor

@export var inventory_data: InventoryData = InventoryData.new()
@export var key_item: ItemData
var accessed : bool = false

func _ready():
	GUI.refresh_interface.emit(self)

func open():
	accessed = true
	toggle_inventory.emit(self)
	$ChestClosed.hide()
	$ChestOpen.show()

func close():
	accessed = false
	interactable_area_exited.emit()
	$ChestClosed.show()
	$ChestOpen.hide()

func _on_interactable_area_body_exited(_body):
	if open:
		close()
	

func _on_interactable_area_interacted(player):
	if not accessed and not key_item:
		open()
	elif accessed:
		close()
	else:
		var player_inventory : InventoryData = player.inventory_data
		var key = player_inventory.use_key_item(key_item)
		if key:
			GUI.float_message(["Used %s" % key_item.name], player)
			key_item = null
			open()
		else:
			GUI.float_message(["Need a %s" % key_item.name], player)
