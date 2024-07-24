extends Node2D
class_name RangedWeaponNode

@onready var weapon_sprite : Sprite2D = $Gun
@onready var projectile_origin : Node2D = $Barrel
var ordinance : ItemDataEquippable


var item_name : String = "Gun"
var heat_level : float = 0 :
	set(value):
		heat_level = clampf(value, 0, ordinance.heat_capacity)
		$Gun/PointLight2D.energy = inverse_lerp(ordinance.heat_capacity, heat_level, .3)
		UIManager.update_hud.emit("heat", value, ordinance.heat_capacity)


var shot_time : int = 0
var original_pos
var original_light_energy 
var overheat_sound_played: bool = false

enum GunState {
	COOLING,
	FIRING,
	OVERHEATED
}
var state : GunState :
	set(value):
		state = value
		$SteamParticles.emitting = false
		$SteamParticles2.emitting = false

func _ready():
	UIManager.update_hud.emit("heat", heat_level, 100)
	original_pos = weapon_sprite.position

func set_equip(_ordinance:  ItemDataEquippable):
	print(ordinance)
	ordinance = _ordinance
	weapon_sprite.texture = ordinance.equipment_sprite
	if ordinance.shot_type == ItemDataEquippable.Shoots.STREAM:
		projectile_origin.add_child(ordinance.get_scene())

func _unhandled_input(event):
	
	if event.is_action_pressed("shoot"):
		if not state == GunState.OVERHEATED:
			state = GunState.FIRING
	elif event.is_action_released("shoot"):
		if not state == GunState.OVERHEATED:
			state = GunState.COOLING

func _physics_process(delta):
	var pivot = wrapi(snapped(global_rotation, PI/4) / (PI/4), 0, 8)
	weapon_sprite.flip_v = true if  pivot in [3, 4, 5] else false
	weapon_sprite.z_index = -1 if pivot == 6 else 4
	if ordinance.shot_type == ItemDataEquippable.Shoots.STREAM:
		for child in projectile_origin.get_children():
			child.emitting = false
	match state:
		GunState.FIRING:
			if shot_time <= 0 and ordinance.shot_type == ItemDataEquippable.Shoots.PROJECTILE:
				shoot()
			elif ordinance.shot_type == ItemDataEquippable.Shoots.STREAM:
				for child in projectile_origin.get_children():
					child.emitting = true
					#child.damage *= ordinance.pellets
					child.projectile.global_rotation_degrees = global_rotation_degrees + randfn(0, ordinance.area / 100)
					heat_level += ordinance.heat_generated * delta
			if heat_level >= ordinance.heat_capacity:
				state = GunState.OVERHEATED
		GunState.COOLING:

			overheat_sound_played = false
			cool_off(delta * 2)
		GunState.OVERHEATED:
			if not overheat_sound_played:
				$Overheat.wait_time = ordinance.heat_capacity * 4 * delta
				$Overheat.start()
				$OverheatHiss.play()
				$SteamParticles.lifetime = ordinance.heat_capacity * delta
				$SteamParticles2.lifetime = ordinance.heat_capacity * delta
				$SteamParticles.emitting = true
				$SteamParticles2.emitting = true
				overheat_sound_played = true
				
	#print(GunState.keys()[state], " | ", heat_level)
	cool_off(delta)
	shot_time -=  delta * 100 + ordinance.fire_rate


func cool_off(delta):
	if !is_zero_approx(heat_level):
		heat_level = lerp(heat_level, 0.0, ordinance.cooldown * delta)
	else:
		heat_level = 0


func shoot():


	for n in ordinance.pellets:
		
		var new_bullet = ordinance.get_scene()
		heat_level +=  ordinance.heat_generated
		new_bullet.global_position = to_global(projectile_origin.position)
		new_bullet.global_rotation_degrees = global_rotation_degrees + randfn(0, ordinance.area / 100)
		projectile_origin.add_child(new_bullet)
		if n == 0:
			shot_time = 100
	var fire_anim = get_tree().create_tween()
	fire_anim.tween_property(weapon_sprite, "position:x", clamp(weapon_sprite.position.x - 2, 0, -4), .3).set_trans(Tween.TRANS_ELASTIC)
	fire_anim.tween_property(weapon_sprite, "position:x", original_pos.x, .3).set_trans(Tween.TRANS_LINEAR)
		

		


func _on_overheat_timeout():
	state = GunState.COOLING
