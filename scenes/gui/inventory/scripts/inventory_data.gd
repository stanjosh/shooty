extends Resource
class_name InventoryData

signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal inventory_updated(inventory_data: InventoryData)

@export var slot_datas: Array[SlotData]
@export var color : Color = Color("white")

func size() -> int:
	return slot_datas.filter(func(slot_data): return slot_data != null).size()

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null
		
func use_key_item(key_item : ItemData) -> bool:
	for index in slot_datas.size():

		if slot_datas[index] \
			and slot_datas[index].item_data \
			and slot_datas[index].item_data == key_item:

			slot_datas[index].quantity -= 1
			if slot_datas[index].quantity < 1:
				slot_datas[index] = null

			inventory_updated.emit(self)
			return true
	return false
	
func use_slot_data(index):
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
	
	if slot_data.item_data is ItemDataConsumable:
		slot_data.quantity -= 1
		
		if slot_data.quantity < 1:
			slot_datas[index] = null
		inventory_updated.emit(self)
	PlayerManager.use_slot_data(slot_data)

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]

	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		
		return_slot_data = slot_data
	inventory_updated.emit(self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func pick_up_slot_data(slot_data : SlotData) -> bool:
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true	

	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true	
	
	
	return false

func on_slot_clicked(index: int, button: int):
	inventory_interact.emit(self, index, button)
