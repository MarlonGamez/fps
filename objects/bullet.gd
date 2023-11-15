extends Area3D
class_name Bullet

var speed: float
var grav: float
var time_spawned: float
var lifetime: float
var damage: float
var spawner_groups: Array[StringName]

func _process(delta):
	var time_since_spawn: float = Time.get_unix_time_from_system() - time_spawned
	position += transform.basis * Vector3(0, 0, speed) * delta
	position += transform.basis * Vector3(0, -grav, 0) * time_since_spawn * delta
	if time_since_spawn > lifetime:
		if not is_queued_for_deletion():
			queue_free()

func _on_body_entered(body: Node3D):
	for group in spawner_groups:
		if body.is_in_group(group):
			return

	if body.has_method("damage"):
		body.damage(damage)

	print("Damage!")
	# Creating an impact animation

	var impact = preload("res://objects/impact.tscn")
	var impact_instance = impact.instantiate()

	impact_instance.play("shot")

	get_tree().root.add_child(impact_instance)

	impact_instance.position = global_position

	if not is_queued_for_deletion():
			queue_free()
