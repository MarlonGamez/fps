extends Resource
class_name AttackRes

@export_subgroup("Properties")
@export var hitboxes: Array[MeleeHitbox] # Positions that the hitbox will move between for the move
@export var damage: int # Damage of the move
@export var combo_time: float # Time after move to transition to next move

@export_subgroup("Sounds")
@export var sound: String # Path to sound file
