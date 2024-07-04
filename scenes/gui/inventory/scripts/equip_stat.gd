extends Resource
class_name EquipStat

@export var random : bool = true
@export var stat : StatName = StatName.AREA if not random else StatName.values()[randi()%StatName.size()]
@export_range(-5, 5) var value : int = 1 if not random else randf_range(-4, 4)

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

