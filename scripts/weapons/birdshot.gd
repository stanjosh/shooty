extends State


@export var active : bool = false

@onready var reload = $reload

@export var damage : int = 2
@export var piercing : int = 5
@export var magazine : int = 1
@export var fire_rate : int = 1
@export var accuracy : float = .09
@export var pellets : int = 8
@export var dropoff : float = 20

@export var texture = Image.load_from_file("res://assets/player/birdshot.png")

