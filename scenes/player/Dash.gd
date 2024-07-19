extends PlayerAction

@onready var dash_cooldown_timer := $DashCooldown
@export var base_dash_speed : float = 180
@export var base_dash_cooldown : float = 2
@export var dash_time : float = .5

var dash_speed : float = 0 :
	get:
		return base_dash_speed + (dash_speed * 5)

var dash_cooldown : float = 0 :
	set(new_value):
		dash_cooldown_timer.wait_time = base_dash_cooldown - (dash_cooldown * 0.25)
		dash_cooldown = clampf(new_value, 0, 4)
	get:
		return base_dash_cooldown - (dash_cooldown * 0.25)
		
		
func _ready():
		$DashTimer.wait_time = dash_time
		

func _physics_process(delta):
	player.speed += dash_speed

func dash() -> void:
	print("dash_time: ", dash_time)
	$DashTimer.wait_time = dash_time
	$DashTimer.start()
	$DashParticles.lifetime = dash_time
	$DashParticles.emitting = true
	$DashSound.play()


func _on_dash_cooldown_timeout():
	print("dash cooldown timeout")
	set_deferred("can_dash", true)


func _on_dash_timer_timeout():
	print("dash timer timeout")
	dash_cooldown_timer.start()
