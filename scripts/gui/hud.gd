extends CanvasLayer

@onready var ammo_counter = $bottomright/ammo_counter
@onready var combo_counter = $bottomleft/combo_counter
@onready var health_counter = $topright/health_counter
@onready var grenade_counter = $topleft/grenade_counter


@onready var world = $"../World"
var ammo_count : int = 0
var max_ammo : int = 0
var combo_count : int = 0
var grenade_count : float = 0
var health_count : int = 0

func _physics_process(_delta):
	
	ammo_count = world.player.gun.current_magazine
	max_ammo = world.player.gun.current_state.magazine
	ammo_counter.text = "%s / %s" % [ammo_count, max_ammo]
	
	combo_count = world.player.combo_counter
	combo_counter.text = "%s" % combo_count
	
	grenade_count = snapped(world.player.gun.grenade_timer, 1)
	grenade_counter.text = "%s" % grenade_count

	health_count = world.player.health
	health_counter.text = "%s" % health_count
	
