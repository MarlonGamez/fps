extends Weapon
class_name ProjectileWeapon

@export_subgroup("Model")
@export var model: PackedScene # Model of the weapon
@export var position: Vector3 # On-screen position
@export var rotation: Vector3 # On-screen rotation
@export var muzzle_position: Vector3 # On-screen position of muzzle flash

@export_subgroup("Properties")
@export_range(1, 20) var max_distance: int = 10 # Fire distance
@export_range(0, 5) var spread: float = 0 # Spread of each shot
@export_range(0, 500) var magazine_size: int = 1 # Magazine size
@export_range(1, 5) var bullets_per_shot: int = 1 # Amount of shots

@export_subgroup("Bullet Properties")
@export_range(1, 50) var bullet_speed: float = 1.0 # Speed of fired bullet
@export_range(0, 50) var bullet_grav: float = 0.0 # Gravity of the fired bullet
@export_range(0, 50) var bullet_lifetime: float = 1.0 # Lifetime of fired bullet

@export_subgroup("Sounds")
@export var sound_shoot: String # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D # Image of crosshair on-screen

var reloading: bool = false
var bullet = load("res://objects/bullet.tscn")
var bullet_inst

func max_shots() -> int:
	return magazine_size

func fire(wielder, head_pos: Vector3, head_aimer: Node3D):
	if "camera" in wielder:
		Audio.play(sound_shoot)
		wielder.container.position.z += 0.25 # Knockback of weapon visual
		wielder.camera.rotation.x += 0.025 # Knockback of camera
		wielder.movement_velocity += Vector3(0, 0, knockback) # Knockback

	# Set muzzle flash position, play animation
	if "muzzle" in wielder:
		wielder.muzzle.play("default")

		wielder.muzzle.rotation_degrees.z = randf_range(-45, 45)
		wielder.muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		wielder.muzzle.position = wielder.container.position - muzzle_position

	# Shoot the weapon, amount based on shot count
	for n in bullets_per_shot:
		var target_pos: Vector3 = Vector3(randf_range(-spread, spread), randf_range(-spread, spread), max_distance)
		bullet_inst = bullet.instantiate()
		bullet_inst.look_at_from_position(wielder.to_global(head_pos), wielder.to_global(head_pos + head_aimer.transform.translated_local(target_pos).origin))
		bullet_inst.position = wielder.to_global(head_pos)
		bullet_inst.time_spawned = Time.get_unix_time_from_system()
		bullet_inst.lifetime = bullet_lifetime
		bullet_inst.speed = bullet_speed
		bullet_inst.grav = bullet_grav
		bullet_inst.damage = damage
		bullet_inst.spawner_groups = wielder.get_groups()
		wielder.get_parent().add_child(bullet_inst)
