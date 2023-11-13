extends Node3D
class_name Bullet

var speed: float
var time_spawned: float
var lifetime: float

func _process(delta):
    position += transform.basis * Vector3(0, 0, -speed) * delta
    if Time.get_unix_time_from_system() - time_spawned > lifetime:
        if not is_queued_for_deletion():
            queue_free()