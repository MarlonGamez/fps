extends Weapon
class_name WeaponMelee

var res: WeaponMeleeRes

var hitbox_res = load("res://objects/hitbox.tscn")

var attack_i = 0
var curr_attack: AttackRes

func _init(r: WeaponMeleeRes):
	self.res = r

func get_cooldown() -> float:
	return get_attack_duration(attack_i) + res.attacks[wrap(attack_i+1, 0, res.attacks.size())].hitboxes[0].delay

func get_attack_duration(i: int) -> float:
	var sum: float = 0.0
	for hitbox in res.attacks[i].hitboxes:
		sum += hitbox.duration

	return sum

func fire(wielder, _head_pos: Vector3, head_aimer: Node3D):
	curr_attack = res.attacks[attack_i]

	var hitbox_inst = hitbox_res.instantiate()
	hitbox_inst.damage = curr_attack.damage
	hitbox_inst.lifetime = 10
	hitbox_inst.spawner_groups = wielder.get_groups()
	hitbox_inst.position = curr_attack.hitboxes[0].position
	head_aimer.add_child(hitbox_inst)

	for i in range(curr_attack.hitboxes.size()-1):
		var from = curr_attack.hitboxes[i]
		var to = curr_attack.hitboxes[i+1]
		var direction = ((to.position - from.position) / to.duration)
		hitbox_inst.velocity = direction
		await wielder.get_tree().create_timer(to.duration).timeout

	attack_i = (attack_i + 1) % res.attacks.size()
	hitbox_inst.queue_free()

func get_combo_time() -> float:
	return get_attack_duration(attack_i) + res.attacks[attack_i].combo_time

func reset_combo():
	attack_i = 0
