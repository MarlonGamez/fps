extends Area3D
class_name HitboxComponent

@export var damage: int

signal hit

var spawner_groups: Array[StringName]

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area3D):
	if is_in_groups(area):
		return

	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.damage(damage)
		hit.emit()

	elif area.get_parent().get_groups().size() > 0:
		hit.emit()


func is_in_groups(area) -> bool:
	for group in spawner_groups:
		if area.get_parent().is_in_group(group):
			return true
	return false


func _on_body_entered(body: Node3D):
	if body is StaticBody3D or body is GridMap:
		hit.emit()
