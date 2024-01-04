extends CharacterBody3D

const SPEED = 2.5
const JUMP_VELOCITY = 4.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var body := $Body
@onready var leg1 := $Body/Leg1
@onready var leg2 := $Body/Leg2

# Fixed vertical offset to keep legs at the bottom
const LEGS_VERTICAL_OFFSET = -1.5
# Fixed horizontal offset for leg spread
const LEGS_HORIZONTAL_OFFSET = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.004)
			camera.rotate_x(-event.relative.y * 0.004)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Calculate the fixed position for the legs at the bottom
	var legs_position = neck.global_transform.origin + camera.global_transform.basis.z.normalized() * LEGS_HORIZONTAL_OFFSET
	legs_position.y += LEGS_VERTICAL_OFFSET

	leg1.global_transform.origin = legs_position + Vector3(-0.5, 0, 0)  # Adjust the spread
	leg2.global_transform.origin = legs_position + Vector3(0.5, 0, 0)   # Adjust the spread

	# Use the camera's basis for orientation
	leg1.global_transform.basis = camera.global_transform.basis
	leg2.global_transform.basis = camera.global_transform.basis
