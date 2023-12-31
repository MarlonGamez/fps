extends Node3D
class_name WeaponComponent

@export var wielder: Node3D
@export var wielder_head: Node3D
@export var head_aimer: Node3D

@export var weapons: Array[WeaponRes] = []
var ws: Array[Weapon] = []
var curr_i: int

signal weapon_changed(magazine_size: int)
signal fired(remaining_bullets: int)
signal reloaded(magazine_size: int)
signal charging(percent: float)
signal combo_time_left(time_left: float, combo_time: float)

@onready var cooldown_timer: Timer = $Cooldown
@onready var reload_timer: Timer = $Reload
@onready var charge_timer: Timer = $Charge
@onready var combo_timer: Timer = $Combo
var combo_time: float = 0

func _ready():
	for w in weapons:
		if w is WeaponProjectileRes:
			ws.append(WeaponProjectile.new(w))
		elif w is WeaponMeleeRes:
			ws.append(WeaponMelee.new(w))
		else:
			print("Unknown weapon type")

	change_weapon(0)
	reload_timer.timeout.connect(_reload_weapon)
	charge_timer.timeout.connect(fire_weapon)
	combo_timer.timeout.connect(reset_combo)

func _physics_process(_delta: float):
	if !charge_timer.is_stopped():
		charging.emit((curr_res().charge_time - charge_timer.time_left) / curr_res().charge_time)

	if !combo_timer.is_stopped():
		combo_time_left.emit(combo_timer.time_left, combo_time)


func size() -> int:
	return weapons.size()

func curr_res() -> WeaponRes:
	return weapons[curr_i]

func curr() -> Weapon:
	return ws[curr_i]

func can_reload(i: int) -> bool:
	return ws[i].get_magazine_remaining() < ws[i].get_magazine_size()

func needs_reload(i: int) -> bool:
	return ws[i].get_magazine_remaining() <= 0

func shots_remaining(i: int) -> int:
	return ws[i].get_magazine_remaining()

func change_weapon(weapon_i: int):
	if !reload_timer.is_stopped():
		reload_timer.stop()
	if weapons.size() == 0:
		return

	curr_i = weapon_i

	weapon_changed.emit(shots_remaining(curr_i))


func activate() -> bool:
	if !reload_timer.is_stopped(): return false # reloading -> don't fire
	if needs_reload(curr_i): # needs reload -> reload
		return reload_weapon()
	if !cooldown_timer.is_stopped(): return false # Cooldown for shooting

	if !combo_timer.is_stopped():
		combo_timer.stop()

	if weapons[curr_i].chargeable:
		start_charging_weapon()
		return false

	fire_weapon()
	return false

func start_charging_weapon():
	if !charge_timer.is_stopped():
		return
	charge_timer.start(curr_res().charge_time)

func fire_weapon():
	combo_time = curr().get_combo_time()
	var cooldown_time: float = curr().get_cooldown()
	curr().fire(wielder, wielder_head.position, head_aimer)
	fired.emit(shots_remaining(curr_i))
	charging.emit(0)
	cooldown_timer.start(cooldown_time)
	combo_timer.start(combo_time)


func deactivate():
	stop_charging_weapon()

func stop_charging_weapon():
	if charge_timer.is_stopped():
		return
	charge_timer.stop()
	charging.emit(0)

func reload_weapon() -> bool:
	if !reload_timer.is_stopped(): return false # already reloading -> don't reload
	if !can_reload(curr_i): return false # cannot reload -> don't reload

	reload_timer.start(curr_res().reload_time)
	return true

func _reload_weapon():
	curr().reload()
	reloaded.emit(curr().get_magazine_remaining())

func reset_combo():
	curr().reset_combo()
	combo_time_left.emit(0, curr().get_combo_time())


