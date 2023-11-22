extends Resource
class_name AttackRes

@export_subgroup("Properties")
@export var hitboxes: Array[MeleeHitbox]
@export var damage: int

@export_subgroup("Sounds")
@export var sound: String # Path to sound file
