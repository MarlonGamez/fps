extends WeaponRes
class_name WeaponMeleeRes

@export_subgroup("Model")
@export var model: PackedScene # Model of the weapon
@export var position: Vector3 # On-screen position
@export var rotation: Vector3 # On-screen rotation

@export_subgroup("Properties")
@export var attacks: Array[AttackRes] # Available attacks for this weapon

@export_subgroup("Crosshair")
@export var crosshair: Texture2D # Image of crosshair on-screen
