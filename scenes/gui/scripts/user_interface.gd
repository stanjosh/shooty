extends CanvasLayer


signal drop_slot_data(slot_data)
signal update_stats(key, value)
signal pause_game()


@onready var pause_menu = $PauseMenu
@onready var inventory_interface = $InventoryInterface
@onready var game_over_menu = $GameOverMenu
@onready var heads_up_display = $HeadsUpDisplay
@onready var main_menu = $MainMenu


var paused: bool

enum MenuName {
	PAUSE,
	MAIN,
	INVENTORY,
	GAME_OVER,
	HUD
}


func mode(menu : MenuName = MenuName.HUD):
	for child in get_children():
		child.hide()
	match menu:
		MenuName.GAME_OVER:
			game_over_menu.show()
		MenuName.INVENTORY:
			pass
		MenuName.PAUSE:
			pause_menu.show()
		MenuName.MAIN:
			main_menu.show()
		MenuName.HUD:
			heads_up_display.show()
		_:
			pass




const FLOATING_STATUS = preload("res://scenes/effects/floating_status.tscn")
func float_message(message : Array[String], global_position, vector : Vector2 = Vector2.ZERO):
	var lines = message.size()
	for line in message:
		var status_msg = FLOATING_STATUS.instantiate()
		lines -= 1
		status_msg.position = global_position
		status_msg.position = Vector2(global_position.x, global_position.y - 8 * lines)
		status_msg.value = line
		status_msg.vector = vector
		call_deferred("add_child", status_msg)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		UiManager.pause_game.emit()

func _on_quit_pressed():
	get_tree().quit()

func _on_inventory_interface_drop_slot_data(slot_data):
	drop_slot_data.emit(slot_data)


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

