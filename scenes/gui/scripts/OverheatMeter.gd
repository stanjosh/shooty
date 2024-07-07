extends Control


var max_heat : float = 100
var current_heat : float = 1



func _process(_delta):
	$OverheatBar.max_value = max_heat
	$OverheatBar/AmmoCounter.text = "%s / %s" % [snapped(current_heat, 1), snapped(max_heat, 1)]
	$OverheatBar.value = current_heat
	var tween = get_tree().create_tween()
	tween.tween_property($OverheatBar, "value", current_heat, .3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)



