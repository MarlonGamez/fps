extends CharacterBody3D
class_name Player

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var vert_velocity: float
var rotation_target: Vector3

var input_mouse: Vector2

var previously_floored := false

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween: Tween

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var weapon_cooldown = $Cooldown

@onready var health: HealthComponent = $Health
@onready var weapons: WeaponComponent = $Weapon
@onready var gravity: GravityComponent = $Gravity
@onready var movement: MovementComponent = $Movement

@export var crosshair: TextureRect

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.depleted.connect(death)
	crosshair.texture = weapons.curr_weapon.crosshair

func _physics_process(delta):

	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)

	# Movement
	var applied_velocity: Vector3

	movement_velocity = transform.basis * movement_velocity # Move forward

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -vert_velocity

	velocity = applied_velocity
	move_and_slide()

	# Rotation
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)

	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)

	container.position = lerp(container.position, container_offset - (applied_velocity / 30), delta * 10)

	# Movement sound
	sound_footsteps.stream_paused = true
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false

	# Landing after jump or falling
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)

	if is_on_floor() and vert_velocity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1

	previously_floored = is_on_floor()

	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()

# Mouse movement
func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		input_mouse = event.relative / mouse_sensitivity
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):
	# Mouse capture
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true

	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false

		input_mouse = Vector2.ZERO

	# Movement
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement.speed

	# Rotation
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")

	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))

	# Shooting
	action_shoot()

	# Jumping
	if is_on_floor():
		movement.reset_jump()
	if Input.is_action_just_pressed("jump"):
		if movement.jump("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg"):
			vert_velocity = -movement.jump_strength

	# Weapon switching
	action_weapon_toggle()

# Handle gravity
func handle_gravity(delta):
	vert_velocity += gravity.GRAVITY * delta

	if vert_velocity > 0 and is_on_floor():
		vert_velocity = 0

# Shooting
func action_shoot():
	if Input.is_action_pressed("shoot"):
		weapons.curr_weapon.fire(self, head.position, camera)

# Toggle between available weapons
func action_weapon_toggle():
	if Input.is_action_just_pressed("weapon_toggle"):
		initiate_change_weapon()

# Initiates the weapon changing animation (tween)
func initiate_change_weapon():
	Audio.play("sounds/weapon_change.ogg")
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)
func change_weapon():
	weapons.change_weapon(wrap(weapons.curr_i + 1, 0, weapons.size()))

	# Step 1. Remove previous weapon model(s) from container
	for n in container.get_children():
		container.remove_child(n)

	# Step 2. Place new weapon model in container
	var weapon_model = weapons.curr_weapon.model.instantiate()
	container.add_child(weapon_model)

	weapon_model.position = weapons.curr_weapon.position
	weapon_model.rotation_degrees = weapons.curr_weapon.rotation

	# Step 3. Set model to only render on layer 2 (the weapon camera)
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2

	# Set weapon data
	crosshair.texture = weapons.curr_weapon.crosshair

func death():
	get_tree().reload_current_scene() # Reset when out of health
