extends Node2D
class_name Weapon


@export var socket_data := InventoryDataSockets.new()

var current_stat_upgrades : Dictionary


func _ready():
	socket_data.connect("inventory_updated", equip_sockets)

func equip_sockets(_socket_data: InventoryDataSockets):
	current_stat_upgrades.clear()
	current_stat_upgrades = _socket_data.consolidated()
	print(current_stat_upgrades)

func update_status():
	pass
