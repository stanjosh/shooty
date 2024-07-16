extends InventoryData
class_name InventoryDataSockets

@export var slot_color : Color


func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataSocketable:

		return grabbed_slot_data

	
	return super.drop_slot_data(grabbed_slot_data, index)
	
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataSocketable:

		return grabbed_slot_data

	
	return super.drop_single_slot_data(grabbed_slot_data, index)

func pick_up_slot_data(slot_data : SlotData) -> bool:
	if slot_data.item_data.weapon_scene:
		return slot_data.item_data.weapon_scene

	
	return super.pick_up_slot_data(slot_data)

func consolidated() -> Dictionary:
	var stat_dict : Dictionary = {}
	var equip_stats := []
	for slot_data in slot_datas:
		if slot_data != null \
		and slot_data.item_data != null \
		and slot_data.item_data is ItemDataSocketable:
			equip_stats.append(slot_data.item_data.consolidated_equip_stats())
	for i in equip_stats:
		for k in i:
			stat_dict[k] = 0
	print(stat_dict)
	if equip_stats:
		for i in equip_stats:
			for k in i:
				stat_dict[k] += i[k]
	


	return stat_dict


	
