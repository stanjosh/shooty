extends Control
class_name LevelUpMenu

const PERK_SELECTION = preload("res://scenes/gui/level_up/perk_selection.tscn")
var perks : Array[LevelPerk]

func _init() -> void:
	visible = false

func _ready() -> void:
	pass
	

func show_perks() -> void:
	for perk in perks:
		var perk_selection = PERK_SELECTION.instantiate()
		perk_selection.perk = perk
		add_child(perk_selection)
		perk_selection.choose_perk.connect(_on_perk_chosen)
	show()
	



func _on_perk_chosen(perk : LevelPerk) -> void:
	perk.apply_perk(PlayerManager.player)
