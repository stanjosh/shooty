extends ProgressBar


func _process(_delta):
	max_value = get_parent().max_health
	value = get_parent().health
