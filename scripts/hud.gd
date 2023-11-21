extends CanvasLayer

@export var player: Player

func _ready():
	$Health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]
	player.health.updated.connect(_on_health_updated)
	player.weapons.reloaded.connect(_on_bullets_updated)
	player.weapons.weapon_changed.connect(_on_bullets_updated)
	player.weapons.fired.connect(_on_bullets_updated)


func _on_health_updated(health):
	$Health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]

func _on_bullets_updated(bullets):
	$Ammo.text = "%s/%s" % [bullets, player.weapons.curr_weapon.max_shots()]
