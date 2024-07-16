extends ItemData
class_name ItemDataSocketable

@export var random : bool = true
@export var area : int = 0
@export var accuracy : int  = 0
@export var cooldown : int = 0
@export var capacity : int  = 0
@export var special : int = 0

enum StatName {
	##sword width / gun pellets / player move speed
	AREA, 
	##sword length / gun acc / player dash speed
	ACCURACY, 
	##sword cooldown / gun fire rate / player dash cooldown
	COOLDOWN,
	##sword damage / gun heat capacity / player health
	CAPACITY,
	## ???
	SPECIAL
}


func consolidated_equip_stats() -> Dictionary:
	var stat_types : Dictionary = {
		StatName.AREA : area,
		StatName.ACCURACY : accuracy,
		StatName.COOLDOWN : cooldown,
		StatName.CAPACITY : capacity,
		StatName.SPECIAL : special
	}
	return stat_types

func generate_description() -> String:
	var stat_descs : Dictionary = {
		"area" : " + %s" % area,
		"accuracy" : " + %s" % accuracy,
		"cooldown" : " + %s" % cooldown,
		"capacity" : " + %s" % capacity,
		"special" : " + %s" % special,
	}
	var desc_string : String = ""
	for key in stat_descs.keys():
		desc_string += "\n%s %s" % [key, stat_descs[key]]
	return desc_string

