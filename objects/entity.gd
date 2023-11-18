extends CharacterBody3D
class_name Entity

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8
@export var max_health: int = 100
@export var base_gravity: float = 0.0

@onready var curr_health: int = max_health
@onready var curr_gravity: float

func damage(amount):
    curr_health -= amount