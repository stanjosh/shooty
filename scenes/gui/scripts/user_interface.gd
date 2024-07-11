extends CanvasLayer


signal drop_slot_data(slot_data)
signal update_stats(key, value)


@onready var pause_menu = $PauseMenu
@onready var inventory_interface = $InventoryInterface
@onready var game_over_menu = $GameOverMenu
@onready var heads_up_display = $HeadsUpDisplay
@onready var main_menu = $MainMenu


enum MenuName {
	PAUSE,
	MAIN,
	INVENTORY,
	GAME_OVER,
	HUD
}

func _ready():
	UIManager.connect("pause_game", _on_pause_pressed)
	UIManager.connect("game_over", _on_game_over)
	
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
			heads_up_display.show()
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


