extends Control

@onready var player : CharacterBody2D = get_node("/root/Game/World/player")
@onready var player_stats : RichTextLabel = %PlayerStats


func _ready():
	update()


func update():
	player_stats.append_text("max health %s\n" % [player.max_health])
	player_stats.append_text("speed %s\n" % [player.speed])
	player_stats.append_text("health per sec %s\n" % [player.health_regen])
	player_stats.append_text("max health %s\n" % [player.max_health])
