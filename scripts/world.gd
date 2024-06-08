extends Node2D

@onready var spawner = %spawner

@onready var player = %player


var mobs : Array
var active_mines : Array

func _process(_delta):

	mobs = get_children().filter(func(child): return child is Mob)
	active_mines = get_children().filter(func(child): return child is Mine)
