extends PanelContainer
@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $QuantityLabel

signal slot_clicked(index: int, button: int)

func set_slot_data(slot_data : SlotData):
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton \
		and (event.button_index == MOUSE_BUTTON_LEFT \
		or event.button_index == MOUSE_BUTTON_RIGHT) \
		and event.is_pressed():
		accept_event()
		slot_clicked.emit(get_index(), event.button_index)
