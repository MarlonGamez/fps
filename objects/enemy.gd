extends CharacterBody3D

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

# Components
@onready var weapons: WeaponComponent = $Weapon

var time := 0.0
var target_position: Vector3

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
		pass
		weapons.fire_weapon(self, raycast.position, raycast)


# Take damage
func _on_health_damaged(_amount):
	Audio.play("sounds/enemy_hurt.ogg")


# Destroy the enemy when out of health
func _on_health_depleted():
	Audio.play("sounds/enemy_destroy.ogg")
	queue_free()
