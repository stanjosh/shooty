extends InventoryData
class_name InventoryDataEquip


@export var equip_type : ItemDataEquippable.EquipType

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquippable \
		or not grabbed_slot_data.item_data.equip_type == equip_type:
		push_error("cannot equip in slot type ", equip_type, " , ", grabbed_slot_data.item_data.equip_type)
		return grabbed_slot_data


	return super.drop_slot_data(grabbed_slot_data, index)
	
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquippable \
		or not grabbed_slot_data.item_data.equip_type == equip_type:
		push_error("cannot equip in slot type ", equip_type, " , ", grabbed_slot_data.item_data.equip_type)
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)



func get_equipped() -> ItemDataEquippable:
	if slot_datas[0]:
		return slot_datas[0].item_data
	else:
		return null
