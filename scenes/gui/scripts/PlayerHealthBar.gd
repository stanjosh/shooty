extends Control

var max_health : float = PlayerManager.player.max_health
var health : float = PlayerManager.player.health


func _process(_delta):
	$Orb/PlayerHealthBar.max_value = float(max_health)
	$Orb/PlayerHealthBar2.max_value = float(max_health)
	$Orb/HealthCounter.text = "%s / %s" % [snapped(health, 1), snapped(max_health, 1)]
	$Orb/PlayerHealthBar.value = float(health)
	var tween = get_tree().create_tween()
	tween.tween_property($Orb/PlayerHealthBar2, "value", health, 1.5).set_ease(Tween.EASE_IN)


