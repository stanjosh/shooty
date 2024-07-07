extends Control
class_name InventoryInterface

const PICKUP_ITEM = preload("res://scenes/gui/inventory/items/pickup_item.tscn")


var grabbed_slot_data: SlotData
var external_inventory_owner


@onready var item_inventory = $PlayerInventory/ItemInventory
@onready var equip_inventory = $PlayerInventory/EquipInventory

@onready var grabbed_slot = $GrabbedSlot
@onready var external_inventory : Control = $ExternalInventory
@onready var player = PlayerManager.player




func _physics_process(_delta):
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	if external_inventory_owner and visible \
		and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 64:
			toggle_inventory_interface()
	if external_inventory_owner:
		var ext_pos = external_inventory_owner.interface_anchor.get_global_transform_with_canvas().origin
		external_inventory.set_position(ext_pos)

func _ready():
	
	
	UIManager.connect("refresh_interface", refresh)

	get_interactables()
	refresh()
	
func refresh(target = null):
	if target:
		if target is Player:
			set_player_inventory_data(target.inventory_data)
			set_equip_inventory_data(target.equip_inventory_datas)
			target.toggle_inventory.connect(toggle_inventory_interface)
		if target is Chest:
			target.toggle_inventory.connect(toggle_inventory_interface)


func get_interactables():
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(_external_inventory_owner = null):
	
	if _external_inventory_owner:
		external_inventory_owner = _external_inventory_owner
		set_external_inventory(external_inventory_owner)
		visible = true
	if not _external_inventory_owner:
		if external_inventory_owner:
			external_inventory_owner.close()
		visible = !visible

func set_external_inventory(_external_inventory_owner):
	external_inventory_owner = _external_inventory_owner
	print("set")
	
	
	var inventory_data = external_inventory_owner.inventory_data
	external_inventory_owner.interactable_area_exited.connect(clear_external_inventory)
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

func clear_external_inventory():
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		external_inventory_owner.interactable_area_exited.disconnect(clear_external_inventory)
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		print("clear")
		external_inventory.hide()
		external_inventory_owner = null



func drop_slot_data_in_map(slot_data):
	var pick_up = PICKUP_ITEM.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = PlayerManager.player.get_global_mouse_position()
	MapManager.current_map.add_child(pick_up)


func set_player_inventory_data(inventory_data: InventoryData):
	inventory_data.inventory_interact.connect(on_inventory_interact)
	item_inventory.set_inventory_data(inventory_data)


func set_equip_inventory_data(inventory_datas: Array[InventoryDataEquip]):
	print("set equip")
	for inventory_data in inventory_datas:
		print(inventory_data.upgrade_target)
		var INVENTORY = load("res://scenes/gui/inventory/inventory.tscn")
		var new_inventory = INVENTORY.instantiate()
		equip_inventory.add_child(new_inventory)
		inventory_data.inventory_interact.connect(on_inventory_interact)
		new_inventory.set_inventory_data(inventory_data)


func on_inventory_interact(inventory_data: InventoryData, index: int, button: int):
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
			accept_event()
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
			accept_event()
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
			accept_event()
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			accept_event()
	
	update_grabbed_slot()


func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.set_slot_data(grabbed_slot_data)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()


func _on_gui_input(event):
	if not event.is_pressed():
		return
	if event is InputEventMouseButton \
		and event.is_pressed() \
		and grabbed_slot_data:
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data_in_map(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data_in_map(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()


func _on_visibility_changed():
	if not visible and grabbed_slot_data:
		drop_slot_data_in_map(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
