extends Resource
class_name Weapon

# @export_subgroup("Properties")
@export_range(0, 1) var cooldown: float = 0.1  # Firerate
@export_range(0, 100) var damage: float = 25  # Damage per hit
@export var knockback: int = 20  # Amount of knockback
@export_range(0, 10.0) var reload_time: float = 0.0 # Time to reload
@export var chargeable: bool = false  # Can the weapon be charged?
@export_range(0, 10.0) var charge_time: float = 0.0 # Time to charge

func needs_reload() -> bool:
	return false

func shots_remaining() -> int:
	return 1

func max_shots() -> int:
	return 1

func charge():
	pass

func fire(_wielder, _wielder_head: Vector3, _head_aimer: Node3D):
	pass

func reload():
	pass
