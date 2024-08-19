extends CanvasLayer


signal drop_slot_data(slot_data)
signal update_stats(key, value)
signal refresh_interface(target)

@onready var pause_menu = $PauseMenu
@onready var inventory_interface = $InventoryInterface
@onready var game_over_menu = $GameOverMenu
@onready var hud = $HeadsUpDisplay
@onready var main_menu = $MainMenu

const FLOATING_STATUS = preload("res://scenes/effects/floating_status.tscn")

func _input(event):
	if event.is_action_pressed("pause"):
		mode(MenuName.PAUSE)

func float_message(message : Array, body : Node2D, vector : Vector2 = Vector2.ZERO):
	print(message[0])
	var position = body.get_global_transform_with_canvas().origin
	var lines = message.size()
	for line in message:
		var status_msg = FLOATING_STATUS.instantiate()
		status_msg.position = Vector2(position.x + 64, position.y - 32 * lines)
		lines -= 1
		status_msg.value = line
		status_msg.vector = vector
		hud.add_child(status_msg)


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
		_:
			hud.show()
			pass

func _on_pause_pressed():
	if !$"/root/Game".paused:
		mode(MenuName.PAUSE)
	else:
		mode()

func  _on_game_over():
	mode(MenuName.GAME_OVER)

func _on_quit_pressed():
	get_tree().quit()

func _on_inventory_interface_drop_slot_data(slot_data):
	drop_slot_data.emit(slot_data)

func _on_restart_button_pressed():
	mode()
	MapManager.current_map.spawn_player()

func _on_play_pressed():
	mode(MenuName.HUD)
	MapManager.load_map()


func _on_dungeon_gen_pressed():
	mode(MenuName.HUD)
	MapManager.load_map("testing")
