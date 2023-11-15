extends Area3D
class_name Hitbox

var time_spawned: float
var lifetime: float
var damage: float
var spawner_group: String
var velocity: Vector3

func _physics_process(delta):
	position += transform.basis * velocity * delta

# func _process(_delta):
	# var time_since_spawn: float = Time.get_unix_time_from_system() - time_spawned
	# if time_since_spawn > lifetime:
	# 	if not is_queued_for_deletion():
	# 		queue_free()

func _on_body_entered(body: Node3D):
	if body.is_in_group(spawner_group):
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

	# if not is_queued_for_deletion():
	# 		queue_free()