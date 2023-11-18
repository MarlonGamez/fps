extends Node3D
class_name WeaponComponent

@export var weapons: Array[Weapon] = []
var curr_weapon: Weapon
var curr_i: int

func _ready():
	change_weapon(0)

func change_weapon(weapon_i: int):
	if weapons.size() == 0:
		return

	curr_weapon = weapons[weapon_i]
	curr_i = weapon_i

func size() -> int:
	return weapons.size()
