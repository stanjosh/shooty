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

func grab_slot_data(index: int) -> SlotData:
	return super.grab_slot_data(index)

func get_weapon_infos():
	return slot_datas.map(get_item_data)
	
func get_item_data(slot_data : SlotData) -> WeaponInfo:
	if slot_data and slot_data.item_data:
		if slot_data.item_data is ItemDataEquippable:
			return slot_data.item_data.weapon_info
	return null

func consolidated_weapon_info() -> WeaponInfo:
	var added_weapon_info : WeaponInfo = WeaponInfo.new()
	for weapon_info in get_weapon_infos():
		if weapon_info != null:
			for property in weapon_info.get_property_list():
				if property["usage"] == 4102:
					added_weapon_info.set(property.name, added_weapon_info.get(property.name) + weapon_info.get(property.name))
	return added_weapon_info
