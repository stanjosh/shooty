extends Control

var max_health : float
var health : float
@onready var player_health_bar: ProgressBar = $Orb/PlayerHealthBar
@onready var player_health_bar_2: ProgressBar = $Orb/PlayerHealthBar2
@onready var health_counter: Label = $Orb/HealthCounter


func _ready() -> void:
	player_health_bar.value = health
	player_health_bar_2.value = health

func _process(_delta):
	player_health_bar.max_value = max_health
	player_health_bar_2.max_value = max_health
	health_counter.text = "%s / %s" % [snapped(health, 1), snapped(max_health, 1)]
	player_health_bar.value = float(health)
	


func _on_player_health_bar_value_changed(value: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player_health_bar_2, "value", value, 1.5).set_ease(Tween.EASE_IN)
