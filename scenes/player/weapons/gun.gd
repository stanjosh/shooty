extends Weapon
class_name Gun


@onready var gun = $Gun

@export var fire_rate : float = 24
@export var accuracy : float = 85
@export var pellets : int = 1
@export var cooldown : float = 1
@export var projectile : Projectile



var item_name : String = "Gun"
var overheated : bool = false
var heat_capacity : float = 0
var shot_time : float = 0
var status : Dictionary
var original_pos
var original_light_energy 

func _ready():
	Hud.update_hud.emit(Hud.Element.HEAT, heat_capacity, 100)
	original_pos = gun.position
	original_light_energy = $PointLight2D.energy
	$PointLight2D.energy = 0
	
func _physics_process(delta):
	shot_time -=  delta * 100 + fire_rate
	$PointLight2D.energy = clampf($PointLight2D.energy - 1 * delta, 0, 5)
	var facing_angle = wrapi(floor(get_angle_to(get_parent().position)), 0, 8)
	gun.flip_v = true if  facing_angle in range(0, 5) else false
	gun.z_index = -1 if facing_angle > 5 else 4
	
	if not overheated and heat_capacity > 0:
		heat_capacity = clamp(heat_capacity - cooldown * 10 * delta, 0, 100)
		Hud.update_hud.emit(Hud.Element.HEAT, heat_capacity, 100)


	if Input.is_action_pressed("shoot"):
		shoot(delta)
	else:
		$CPUParticles2D.emitting = false

func shoot(delta):
	if shot_time > 0 or overheated:
		$CPUParticles2D.emitting = false
	if not overheated and shot_time <= 0:
		$CPUParticles2D.emitting = true
		for n in pellets:
			heat_capacity +=  projectile.heat_generated * .25
			var new_bullet = projectile.get_scene()
			new_bullet.global_position = to_global(position)
			var accuracy_calc = clampf(accuracy / 100, 0, 1) * .1
			new_bullet.global_rotation = global_rotation + randf_range(-accuracy_calc, accuracy_calc)
			add_child(new_bullet)
			if n == 0:
				shot_time = 100
				$GunFire.play()
		var fire_anim = get_tree().create_tween()
		$PointLight2D.energy = clampf($PointLight2D.energy + .3, 0, 5)
		fire_anim.tween_property(gun, "position:x", clamp(gun.position.x - 2, 0, original_pos.x), .2).set_trans(Tween.TRANS_ELASTIC)
		

	if not overheated and heat_capacity >= 100:
		overheated = true
		$Overheat.wait_time = cooldown
		$Overheat.start()
	Hud.update_hud.emit(Hud.Element.HEAT, heat_capacity, 100)
	

func _on_overheat_timeout():
	overheated = false
	heat_capacity = 50
	Hud.update_hud.emit(Hud.Element.HEAT, heat_capacity, 100)


