extends Weapon
class_name WeaponMelee

var res: WeaponMeleeRes

var hitbox_res = load("res://objects/hitbox.tscn")

var attack_i = 0
var curr_attack: AttackRes

func _init(r: WeaponMeleeRes):
	self.res = r

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