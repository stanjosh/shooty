extends CanvasLayer


signal drop_slot_data(slot_data)
signal refresh_interface(target)

@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOverMenu
@onready var hud = $HeadsUpDisplay
@onready var main_menu = $MainMenu
@onready var perk_selection: PerkSelection = $PerkSelection

var paused : bool = false


const FLOATING_STATUS = preload("res://scenes/effects/floating_status.tscn")

func _input(event):
	if event.is_action_pressed("pause"):
		pause()


func float_message(message : Array, body : Node2D, vector : Vector2 = Vector2.ZERO):
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
	PERK_SELECTION,
	GAME_OVER,
	HUD
}

func mode(menu : MenuName = MenuName.HUD):
	
	for child in get_children():
		child.hide()
	match menu:
		MenuName.GAME_OVER:
			game_over_menu.show()
		MenuName.PERK_SELECTION:
			perk_selection.show()
		MenuName.PAUSE:
			MapManager.process_mode = Node.PROCESS_MODE_DISABLED
			pause_menu.show()
			hud.show()
		MenuName.MAIN:
			main_menu.show()
		_:
			MapManager.process_mode = Node.PROCESS_MODE_ALWAYS
			hud.show()
			pass

func pause():
	if !paused:
		mode(MenuName.PAUSE)
	elif paused:
		mode()
	paused = !paused

func _on_pause_pressed():
	pause()

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
