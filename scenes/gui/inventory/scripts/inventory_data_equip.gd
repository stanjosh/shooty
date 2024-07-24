extends InventoryData
class_name InventoryDataEquip


func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquippable:

		return grabbed_slot_data

	
	return super.drop_slot_data(grabbed_slot_data, index)
	
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquippable:

		return grabbed_slot_data

	
	return super.drop_single_slot_data(grabbed_slot_data, index)

func get_equipped() -> ItemDataEquippable:
	print("getting equip")
	return slot_datas[0].item_data
