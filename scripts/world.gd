extends Node2D

@onready var player = %player


var mobs : Array
var active_mines : Array


func _ready():
	for map in get_children():
		if map is Map:
			map.player = player

func _process(_delta):

	mobs = get_children().filter(func(child): return child is Mob)
	active_mines = get_children().filter(func(child): return child is Mine)
