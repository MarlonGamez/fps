extends Area3D
class_name Hitbox

var time_spawned: float
var lifetime: float
var damage: float
var spawner_groups: Array[StringName]
var velocity: Vector3

func _physics_process(delta):
	position += transform.basis * velocity * delta

func _on_body_entered(body: Node3D):
	for group in spawner_groups:
		if body.is_in_group(group):
			return

	if body.has_method("damage"):
		body.damage(damage)

	# Creating an impact animation
	var impact = preload("res://objects/impact.tscn")
	var impact_instance = impact.instantiate()

	impact_instance.play("shot")

	get_tree().root.add_child(impact_instance)

	impact_instance.position = global_position
