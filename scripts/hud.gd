extends CanvasLayer

@export var player: Player

func _ready():
	$Health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]
	player.health.updated.connect(_on_health_updated)

func _on_health_updated(health):
	$Health.text = "%s/%s" % [player.health.health, player.health.MAX_HEALTH]
