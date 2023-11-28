extends Node3D
class_name Hitbox

var time_spawned: float
var lifetime: float
var damage: int
var spawner_groups: Array[StringName]
var velocity: Vector3

@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var particles: GPUParticles3D = $Particles

func _ready():
	hitbox.hit.connect(_on_hit)
	hitbox.damage = damage

func _physics_process(delta):
	position += transform.basis * velocity * delta

func _on_hit():
	# Creating an impact animation
	var impact = preload("res://objects/impact.tscn")
	var impact_instance = impact.instantiate()
	impact_instance.play("shot")
	impact_instance.position = global_position

	get_tree().root.add_child(impact_instance)
