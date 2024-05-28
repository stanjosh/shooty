extends State

@onready var reload = $reload

@export var damage : int = 5
@export var piercing : int = 5
@export var magazine : int = 1
@export var fire_rate : int = 1
@export var accuracy : float = .3
@export var pellets : int = 8
@export var dropoff : float = 7

@export var texture = Image.load_from_file("res://assets/player/birdshot.png")

