extends Node3D
class_name WeaponComponent

@export var wielder: Node3D
@export var wielder_head: Node3D
@export var head_aimer: Node3D


@export var weapons: Array[Weapon] = []
var ammo_counts: Array[int]
var curr_i: int

signal weapon_changed(magazine_size: int)
signal fired(remaining_bullets: int)
signal reloaded(magazine_size: int)
signal charging(percent: float)

@onready var cooldown_timer = $Cooldown
@onready var reload_timer = $Reload
@onready var charge_timer = $Charge

func _ready():
	for w in weapons:
		ammo_counts.append(w.max_shots())
	change_weapon(0)
	# reload_weapon()
	reload_timer.timeout.connect(_reload_weapon)
	charge_timer.timeout.connect(fire_weapon)

func _physics_process(_delta: float):
	if !charge_timer.is_stopped():
		charging.emit((curr().charge_time - charge_timer.time_left) / curr().charge_time)


func size() -> int:
	return weapons.size()

func curr() -> Weapon:
	return weapons[curr_i]

func can_reload(i: int) -> bool:
	return ammo_counts[i] < weapons[i].max_shots()

func needs_reload(i: int) -> bool:
	return ammo_counts[i] <= 0

func shots_remaining(i: int) -> int:
	return ammo_counts[i]

func change_weapon(weapon_i: int):
	if !reload_timer.is_stopped():
		reload_timer.stop()
	if weapons.size() == 0:
		return

	curr_i = weapon_i

	weapon_changed.emit(shots_remaining(curr_i))


func activate():
	if !reload_timer.is_stopped(): return # reloading -> don't fire
	if needs_reload(curr_i): # needs reload -> reload
		reload_weapon()
		return
	if !cooldown_timer.is_stopped(): return # Cooldown for shooting

	if curr().chargeable:
		start_charging_weapon()
		return

	fire_weapon()

func start_charging_weapon():
	if !charge_timer.is_stopped():
		return
	charge_timer.start(curr().charge_time)

func fire_weapon():
	curr().fire(wielder, wielder_head.position, head_aimer)
	ammo_counts[curr_i] -= 1
	fired.emit(shots_remaining(curr_i))
	charging.emit(0)
	cooldown_timer.start(curr().cooldown)


func deactivate():
	stop_charging_weapon()

func stop_charging_weapon():
	if charge_timer.is_stopped():
		return
	charge_timer.stop()
	charging.emit(0)

func reload_weapon():
	if !reload_timer.is_stopped(): return # already reloading -> don't reload
	reload_timer.start(curr().reload_time)

func _reload_weapon():
	print("reload callback")
	ammo_counts[curr_i] = curr().max_shots()
	reloaded.emit(curr().max_shots())


