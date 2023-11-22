extends Weapon
class_name WeaponProjectile

var res: WeaponProjectileRes

var bullet = load("res://objects/bullet.tscn")
var bullet_inst

var magazine_remaining: int

func _init(r: WeaponProjectileRes):
	self.res = r
	self.magazine_remaining = res.magazine_size

func get_magazine_size() -> int:
	return res.magazine_size

func get_magazine_remaining() -> int:
	return magazine_remaining

func fire(wielder, head_pos: Vector3, head_aimer: Node3D):
	if "camera" in wielder:
		Audio.play(res.sound_shoot)
		wielder.container.position.z += 0.25 # Knockback of weapon visual
		wielder.camera.rotation.x += 0.025 # Knockback of camera
		wielder.movement_velocity += Vector3(0, 0, res.knockback) # Knockback

	# Set muzzle flash position, play animation
	if "muzzle" in wielder:
		wielder.muzzle.play("default")

		wielder.muzzle.rotation_degrees.z = randf_range(-45, 45)
		wielder.muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		wielder.muzzle.position = wielder.container.position - res.muzzle_position

	# Shoot the weapon, amount based on shot count
	magazine_remaining -= 1
	for n in res.bullets_per_shot:
		var target_pos: Vector3 = Vector3(randf_range(-res.spread, res.spread), randf_range(-res.spread, res.spread), res.max_distance)
		bullet_inst = bullet.instantiate()
		bullet_inst.look_at_from_position(wielder.to_global(head_pos), wielder.to_global(head_pos + head_aimer.transform.translated_local(target_pos).origin))
		bullet_inst.position = wielder.to_global(head_pos)
		bullet_inst.time_spawned = Time.get_unix_time_from_system()
		bullet_inst.lifetime = res.bullet_lifetime
		bullet_inst.speed = res.bullet_speed
		bullet_inst.grav = res.bullet_grav
		bullet_inst.damage = res.damage
		bullet_inst.spawner_groups = wielder.get_groups()
		wielder.get_parent().add_child(bullet_inst)

func reload():
	magazine_remaining = res.magazine_size