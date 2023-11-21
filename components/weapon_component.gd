extends Node3D
class_name WeaponComponent

@export var weapons: Array[Weapon] = []
var curr_weapon: Weapon
var curr_i: int

signal weapon_changed(magazine_size: int)
signal fired(remaining_bullets: int)
signal reloaded(magazine_size: int)

@onready var cooldown_timer = $Cooldown
@onready var reload_timer = $Reload

func _ready():
	change_weapon(0)
	reload_weapon()

func size() -> int:
	return weapons.size()

func change_weapon(weapon_i: int):
	if weapons.size() == 0:
		return

	curr_weapon = weapons[weapon_i]
	curr_i = weapon_i
	reload_timer.timeout.connect(_reload_weapon)
	weapon_changed.emit(curr_weapon.max_shots())

func fire_weapon(wielder, wielder_head: Vector3, head_aimer: Node3D):
	if !reload_timer.is_stopped():
		print("reloading")
		return # reloading -> don't fire
	if curr_weapon.needs_reload(): # needs reload -> reload
		print("needs reload")
		reload_weapon()
		return
	if !cooldown_timer.is_stopped():
		print("weapon cooldown")
		return # Cooldown for shooting

	curr_weapon.fire(wielder, wielder_head, head_aimer)
	fired.emit(curr_weapon.shots_remaining())
	cooldown_timer.start(curr_weapon.cooldown)


func reload_weapon():
	if !reload_timer.is_stopped(): return # already reloading -> don't reload
	reload_timer.start(curr_weapon.reload_time)

func _reload_weapon():
	print("reload callback")
	curr_weapon.reload()
	reloaded.emit(curr_weapon.max_shots())