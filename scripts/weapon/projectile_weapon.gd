extends Weapon
class_name ProjectileWeapon

@export_subgroup("Model")
@export var model: PackedScene  # Model of the weapon
@export var position: Vector3  # On-screen position
@export var rotation: Vector3  # On-screen rotation
@export var muzzle_position: Vector3  # On-screen position of muzzle flash

@export var bullet_model: PackedScene # Model of the bullet

@export_subgroup("Properties")
@export_range(0, 1) var cooldown: float = 0.1  # Firerate
@export_range(1, 20) var max_distance: int = 10  # Fire distance
@export_range(0, 100) var damage: float = 25  # Damage per hit
@export_range(0, 5) var spread: float = 0  # Spread of each shot
@export_range(1, 5) var shot_count: int = 1  # Amount of shots
@export_range(0, 50) var knockback: int = 20  # Amount of knockback

@export_range(1, 50) var bullet_speed: float = 1.0 # Speed of fired bullet
@export_range(0, 50) var bullet_grav: float = 0.0 # Gravity of the fired bullet
@export_range(0, 50) var bullet_lifetime: float = 1.0 # Lifetime of fired bullet

@export_subgroup("Sounds")
@export var sound_shoot: String  # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D  # Image of crosshair on-screen

var bullet = load("res://objects/bullet.tscn")
var bullet_inst

func fire(wielder):
    if !wielder.weapon_cooldown.is_stopped(): return # Cooldown for shooting

    Audio.play(sound_shoot)

    wielder.container.position.z += 0.25 # Knockback of weapon visual
    wielder.camera.rotation.x += 0.025 # Knockback of camera
    wielder.movement_velocity += Vector3(0, 0, knockback) # Knockback

    # Set muzzle flash position, play animation

    wielder.muzzle.play("default")

    wielder.muzzle.rotation_degrees.z = randf_range(-45, 45)
    wielder.muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
    wielder.muzzle.position = wielder.container.position - muzzle_position

    wielder.weapon_cooldown.start(cooldown)

    # Shoot the weapon, amount based on shot count

    for n in shot_count:

        var offset_x = randf_range(-spread, spread)
        var offset_y = randf_range(-spread, spread)
        wielder.raycast.target_position = Vector3(0, 0, -1) * max_distance
        wielder.raycast.target_position.x = offset_x
        wielder.raycast.target_position.y = offset_y

        bullet_inst = bullet.instantiate()
        bullet_inst.look_at_from_position(wielder.head.global_position, wielder.to_global(wielder.head.position + wielder.camera.transform.translated_local(wielder.raycast.target_position).origin))
        bullet_inst.position = wielder.head.global_position
        bullet_inst.time_spawned = Time.get_unix_time_from_system()
        bullet_inst.lifetime = bullet_lifetime
        bullet_inst.speed = bullet_speed
        bullet_inst.grav = bullet_grav
        bullet_inst.damage = damage
        bullet_inst.spawner_group= "player"
        wielder.get_parent().add_child(bullet_inst)
