extends CanvasLayer

@export var player: Player

@onready var health: Label = $Health
@onready var ammo: Label = $Ammo
@onready var charge: ProgressBar = $Charge

func _ready():
	health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]
	player.health.updated.connect(_on_health_updated)
	player.weapons.reloaded.connect(_on_bullets_updated)
	player.weapons.weapon_changed.connect(_on_bullets_updated)
	player.weapons.fired.connect(_on_bullets_updated)
	player.weapons.charging.connect(_on_charge_updated)


func _on_health_updated(_health_delta: int):
	health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]

func _on_bullets_updated(bullets):
	ammo.text = "%s/%s" % [bullets, player.weapons.curr_weapon.max_shots()]

func _on_charge_updated(percent: float):
	charge.set_value_no_signal(percent)
