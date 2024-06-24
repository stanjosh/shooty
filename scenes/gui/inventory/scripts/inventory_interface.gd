extends Control

signal drop_slot_data(slot_data : SlotData)

const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")

var grabbed_slot_data: SlotData
var external_inventory_owner

@onready var player_inventory = $HSplitContainer/VSplitContainer/PlayerInventory
@onready var grabbed_slot = $GrabbedSlot
@onready var external_inventory = $HSplitContainer/ExternalInventory
@onready var equip_inventory = $HSplitContainer/VSplitContainer/EquipInventory
@onready var player = PlayerManager.player

func _physics_process(delta):
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	if external_inventory_owner and visible \
		and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 64:
			toggle_inventory_interface()
	
	
func _ready():
	player.toggle_inventory.connect(toggle_inventory_interface)
	set_player_inventory_data(player.inventory_data)
	set_equip_inventory_data(player.equip_inventory_data)

	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(_external_inventory_owner = null):
	visible = !visible
	external_inventory_owner = _external_inventory_owner
	if external_inventory_owner and visible:
		set_external_inventory(external_inventory_owner)
	else:
		clear_external_inventory()
		
func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PICKUP_ITEM.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_global_mouse_position()
	add_child(pick_up)






func set_player_inventory_data(inventory_data: InventoryData):
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)

func set_equip_inventory_data(inventory_data: InventoryData):
	inventory_data.inventory_interact.connect(on_inventory_interact)
	equip_inventory.set_inventory_data(inventory_data)

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int):
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()


func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.set_slot_data(grabbed_slot_data)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()

func set_external_inventory(_external_inventory_owner):
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

func clear_external_inventory():
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
	
		external_inventory.hide()
		external_inventory_owner = null
	
func _unhandled_input(event):
	if not event.is_pressed():
		return
	if event is InputEventMouseButton \
		and event.is_pressed() \
		and grabbed_slot_data:
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()


func _on_visibility_changed():
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
