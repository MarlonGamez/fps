extends Node3D

@export var player: Node3D
@export var weapon: Weapon

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB
@onready var weapon_cooldown = $Timer

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false

# When ready, save the initial position
func _ready():
	target_position = position


func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP)  # Look at player
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)

	time += delta

	position = target_position

	raycast.force_raycast_update()
	if raycast.is_colliding():
		weapon.fire(self, raycast.position, raycast)


# Take damage
func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()


# Destroy the enemy when out of health
func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	queue_free()
