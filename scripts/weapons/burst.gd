extends State

@onready var reload = $reload

@export var damage : int = 7
@export var piercing : int = 1
@export var magazine : int = 3
@export var fire_rate : int = 16
@export var accuracy : float = .03
@export var pellets : int = 1
@export var dropoff : float = 15


@export var texture = Image.load_from_file("res://assets/player/automatic.png")

