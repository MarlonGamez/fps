extends Entity

var weapon: Weapon
var weapon_index := 0

var bullet = load("res://objects/bullet.tscn")
var bullet_inst

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

signal health_updated

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var weapon_cooldown = $Cooldown

@export var crosshair:TextureRect

# Functions

func _ready():

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	weapon = weapons[weapon_index] # Weapon must never be nil
	initiate_change_weapon(weapon_index)

func _physics_process(delta):

	# Handle functions

	handle_controls(delta)
	handle_gravity(delta)

	# Movement

	var applied_velocity: Vector3

	movement_velocity = transform.basis * movement_velocity # Move forward

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -curr_gravity

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

	if is_on_floor() and curr_gravity > 1 and !previously_floored: # Landed
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

	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed

	# Rotation

	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")

	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))

	# Shooting

	action_shoot()

	# Jumping

	if Input.is_action_just_pressed("jump"):

		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")

		if jump_double:

			curr_gravity = -jump_strength
			jump_double = false

		if(jump_single): action_jump()

	# Weapon switching

	action_weapon_toggle()

# Handle gravity
func handle_gravity(delta):
	curr_gravity += base_gravity * delta

	if curr_gravity > 0 and is_on_floor():
		jump_single = true
		curr_gravity = 0

# Jumping
func action_jump():
	curr_gravity = -jump_strength

	jump_single = false;
	jump_double = true;

# Shooting
func action_shoot():

	if Input.is_action_pressed("shoot"):
		weapon.fire(self, head.position, camera)


# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():

	if Input.is_action_just_pressed("weapon_toggle"):

		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon(weapon_index)

		Audio.play("sounds/weapon_change.ogg")

# Initiates the weapon changing animation (tween)

func initiate_change_weapon(index):

	weapon_index = index

	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)

func change_weapon():

	weapon = weapons[weapon_index]

	# Step 1. Remove previous weapon model(s) from container

	for n in container.get_children():
		container.remove_child(n)

	# Step 2. Place new weapon model in container

	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)

	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation

	# Step 3. Set model to only render on layer 2 (the weapon camera)

	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2

	# Set weapon data

	# raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair

func damage(amount):
	super(amount)

	health_updated.emit(curr_health) # Update health on HUD
	if curr_health < 0:
		get_tree().reload_current_scene() # Reset when out of health
