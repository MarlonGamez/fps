extends Weapon
class_name MeleeWeapon

@export_subgroup("Model")
@export var model: PackedScene  # Model of the weapon
@export var position: Vector3  # On-screen position
@export var rotation: Vector3  # On-screen rotation

@export_subgroup("Properties")
@export_range(0, 1) var cooldown: float = 0.1  # Firerate
@export_range(0, 100) var damage: float = 25  # Damage per hit
@export_range(0, 50) var knockback: int = 20  # Amount of knockback
@export var hitboxes: Array[MeleeHitbox]

@export_range(1, 50) var bullet_speed: float = 1.0 # Speed of fired bullet
@export_range(0, 50) var bullet_grav: float = 0.0 # Gravity of the fired bullet
@export_range(0, 50) var bullet_lifetime: float = 1.0 # Lifetime of fired bullet

@export_subgroup("Sounds")
@export var sound_shoot: String  # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D  # Image of crosshair on-screen

var hitbox_res = load("res://objects/hitbox.tscn")
var hitbox_inst

func fire(wielder):
	if !wielder.weapon_cooldown.is_stopped(): return

	wielder.weapon_cooldown.start(cooldown)

	for hb in hitboxes:
		await wielder.get_tree().create_timer(hb.delay).timeout
		hitbox_inst = hitbox_res.instantiate()
		hitbox_inst.time_spawned = Time.get_unix_time_from_system()
		hitbox_inst.lifetime = hb.duration
		hitbox_inst.damage = damage
		hitbox_inst.spawner_group = "player"
		hitbox_inst.position = wielder.head.to_global(wielder.camera.transform.translated_local(hb.position).origin)

		wielder.get_parent().add_child(hitbox_inst)
		await wielder.get_tree().create_timer(hb.duration).timeout

