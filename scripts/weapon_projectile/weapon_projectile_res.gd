extends WeaponRes
class_name WeaponProjectileRes

@export_subgroup("Model")
@export var model: PackedScene # Model of the weapon
@export var position: Vector3 = Vector3(0, 0, 0) # On-screen position
@export var rotation: Vector3 = Vector3(0, 180, 0) # On-screen rotation
@export var muzzle_position: Vector3 = Vector3(0.1, -0.4, 1.5) # On-screen position of muzzle flash

@export_subgroup("Properties")
@export_range(1, 20) var max_distance: int = 10 # Fire distance
@export_range(0, 5) var spread: float = 0.3 # Spread of each shot
@export_range(0, 500) var magazine_size: int = 10 # Magazine size
@export_range(1, 5) var bullets_per_shot: int = 1 # Amount of shots

@export_subgroup("Bullet Properties")
@export_range(1, 50) var bullet_speed: float = 15.0 # Speed of fired bullet
@export_range(0, 50) var bullet_grav: float = 0.0 # Gravity of the fired bullet
@export_range(0, 50) var bullet_lifetime: float = 1.0 # Lifetime of fired bullet

@export_subgroup("Sounds")
@export var sound_shoot: String = "assets/sounds/blaster_repeater.ogg" # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D # Image of crosshair on-screen
