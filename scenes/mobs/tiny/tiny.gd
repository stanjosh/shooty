extends Mob




@export_category("Special Attack")

var puddles_left: int =  3

func _physics_process(delta):
	
	if puddles_left and attack_cooldown <= 0:
		pass
		
	
	return super._physics_process(delta)



