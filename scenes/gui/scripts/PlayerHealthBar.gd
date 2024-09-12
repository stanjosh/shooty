extends Control

var max_health : float = 100
var health : float = 100 : 
	set(value):
		health_counter.text = "%s / %s" % [snapped(value, 1), snapped(max_health, 1)]
		player_health_bar.value = float(value)
		var tween = get_tree().create_tween()
		tween.tween_property(player_health_bar_2, "value", float(value), 1).set_ease(Tween.EASE_IN).from_current()
		health = value
		
@onready var player_health_bar: ProgressBar = $Orb/PlayerHealthBar
@onready var player_health_bar_2: ProgressBar = $Orb/PlayerHealthBar2
@onready var health_counter: Label = $Orb/HealthCounter


func _ready() -> void:
	player_health_bar.max_value = max_health
	player_health_bar_2.max_value = max_health
	player_health_bar.value = health
	player_health_bar_2.value = health
