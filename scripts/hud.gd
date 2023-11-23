extends CanvasLayer

@export var player: Player

@onready var health: Label = $Health
@onready var ammo: Label = $Ammo
@onready var charge: ProgressBar = $Charge
@onready var combo: ProgressBar = $Combo

func _ready():
	health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]
	ammo.text = "%s/%s" % [player.weapons.curr().get_magazine_remaining(), player.weapons.curr().get_magazine_size()]

	player.health.updated.connect(_on_health_updated)
	player.weapons.reloaded.connect(_on_bullets_updated)
	player.weapons.weapon_changed.connect(_on_bullets_updated)
	player.weapons.fired.connect(_on_bullets_updated)
	player.weapons.charging.connect(_on_charge_updated)
	player.weapons.combo_time_left.connect(_on_combo_time_updated)


func _on_health_updated(_health_delta: int):
	health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]

func _on_bullets_updated(bullets):
	ammo.text = "%s/%s" % [bullets, player.weapons.curr().get_magazine_size()]

func _on_charge_updated(percent: float):
	charge.set_value_no_signal(percent)

func _on_combo_time_updated(time_left: float, combo_time: float):
	combo.set_max(combo_time)
	combo.set_value_no_signal(time_left)
