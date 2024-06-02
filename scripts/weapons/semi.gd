extends State


@export var active : bool = false

@onready var reload = $reload
@export var damage : int = 11
@export var piercing : int = 4
@export var magazine : int = 6
@export var fire_rate : int = 2
@export var accuracy : float = 0.025
@export var pellets : int = 1
@export var dropoff : float = 25

@export var texture = Image.load_from_file("res://assets/player/semi.png")

