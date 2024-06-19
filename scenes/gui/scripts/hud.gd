extends CanvasLayer

@onready var AmmoCounter = $BottomRight/AmmoCounter

@onready var HealthCounter = $TopRight/HealthCounter
@onready var MineCounter = $BottomLeft/MineCounter
@onready var XPCounter = $TopLeft/XPCounter
@onready var world = $"../World"

var ammo_count : int = 0
var max_ammo : int = 0
var grenade_count : float = 0
var xp_count: int
var max_xp : int
var health_count : int = 0

func _ready():
	Hud.update_hud.connect(on_hud_update)


func on_hud_update(element : String, value, max_value):
	get(element).text = "%s / %s" % [snapped(value, 1), snapped(max_value, 1)]
