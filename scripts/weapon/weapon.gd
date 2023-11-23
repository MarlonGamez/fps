extends Object
class_name Weapon

func get_cooldown() -> float:
	return 0.0

func get_magazine_size() -> int:
	return 1

func get_magazine_remaining() -> int:
	return 1

func charge():
	pass

func fire(_wielder, _wielder_head: Vector3, _head_aimer: Node3D):
	pass

func reload():
	pass

func get_combo_time() -> float:
	return 0.0

func reset_combo():
	pass
