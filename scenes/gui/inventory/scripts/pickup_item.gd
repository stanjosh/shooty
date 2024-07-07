extends Area2D

@export var slot_data : SlotData

@onready var sprite_2d = $Sprite2D
@onready var quantity_label = $QuantityLabel

func _ready():
	sprite_2d.texture = slot_data.item_data.texture
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
	else:
		quantity_label.visible = false


func _on_body_entered(body):
	body.inventory_data.pick_up_slot_data(slot_data)
	UIManager.float_message(["+%s (%s)" % [slot_data.item_data.name, slot_data.quantity]], global_position)
	queue_free()
