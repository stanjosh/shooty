@tool
extends Area2D
class_name PickupItem

@export var slot_data : SlotData

@onready var sprite_2d = $Sprite2D
@onready var quantity_label = $Sprite2D/QuantityLabel

func _get_configuration_warnings():
	update_configuration_warnings()

func _ready():
	sprite_2d.texture = slot_data.item_data.texture
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
	else:
		quantity_label.visible = false


func _on_body_entered(body):
	var message : Array[String]
	if slot_data.item_data and slot_data.item_data.get("use_immediately"):
		slot_data.item_data.use(body)
	else:
		message = ["+%s (%s)" % [slot_data.item_data.name, slot_data.quantity]]
		body.inventory_data.pick_up_slot_data(slot_data)
		GUI.float_message(message, self)
	queue_free()
