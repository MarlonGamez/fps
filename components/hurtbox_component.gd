extends Area3D
class_name HurtboxComponent

@export var health: HealthComponent

func damage(amount: int):
	health.damage(amount)
