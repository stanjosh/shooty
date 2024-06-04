extends State

@export var active : bool = false

@onready var reload = $reload

@export var damage : int = 6
@export var piercing : int = 0
@export var magazine : int = 30
@export var fire_rate : int = 12
@export var accuracy : float = .09
@export var pellets : int = 1
@export var dropoff : float = 10

