extends ItemData
class_name ItemDataEquip

@export var equip_stats : Array[EquipStat]

func consolidated_equip_stats() -> Dictionary:
	var stat_types : Dictionary = {
		EquipStat.StatName.AREA : 0,
		EquipStat.StatName.ACCURACY : 0,
		EquipStat.StatName.COOLDOWN : 0,
		EquipStat.StatName.CAPACITY : 0,
		EquipStat.StatName.SPECIAL : 0
	}
	for stat_type in stat_types:
		for ug in equip_stats:
			if ug != null and ug.stat == stat_type:
				stat_types[stat_type] += ug.value
	return stat_types
