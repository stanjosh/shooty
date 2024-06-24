extends InventoryData
class_name InventoryDataEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)
	
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	
	return super.drop_single_slot_data(grabbed_slot_data, index)

func pick_up_slot_data(slot_data : SlotData) -> bool:
	if slot_data.item_data.weapon_scene:
		return slot_data.item_data.weapon_scene
	
	return super.pick_up_slot_data(slot_data)

