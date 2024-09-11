extends StaticBody2D
class_name Chest

signal toggle_inventory(external_inventory_owner)
signal interactable_area_exited()
@onready var interface_anchor = $InterfaceAnchor
