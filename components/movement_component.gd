extends Node3D
class_name MovementComponent

@export var speed: float

@export_group("Jumping")
@export var jump_strength: float = 5.0
@export var num_jumps: int = 2
var curr_jump = 0

func jump(sound: String) -> bool:
	if curr_jump < num_jumps:
		curr_jump += 1
		Audio.play(sound)
		return true

	return false

func reset_jump():
	curr_jump = 0
