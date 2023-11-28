extends Resource
class_name WeaponRes

# @export_subgroup("Properties")
@export_range(0, 1) var cooldown: float = 0.2  # Firerate
@export_range(0, 100) var damage: float = 20  # Damage per hit
@export var knockback: int = 20  # Amount of knockback
@export_range(0, 10.0) var reload_time: float = 1.0 # Time to reload
@export var chargeable: bool = false  # Can the weapon be charged?
@export_range(0, 10.0) var charge_time: float = 0.0 # Time to charge
