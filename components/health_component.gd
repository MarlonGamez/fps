extends Node3D
class_name HealthComponent

@export var MAX_HEALTH: int
var health: int

signal updated(total: int)
signal healed(amount: int)
signal damaged(amount: int)
signal depleted

func _ready():
	health = MAX_HEALTH

func heal(amount: int):
	health += amount
	healed.emit(amount)
	updated.emit(health)

func damage(amount: int):
	health -= amount
	damaged.emit(amount)
	updated.emit(health)

	if health <= 0:
		depleted.emit()
		var parent = get_parent()
		if not parent.is_queued_for_deletion():
			parent.queue_free()
