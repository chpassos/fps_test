extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Captures mouse movement
var _mouse_input: bool = false # is the mouse moving?
var _rotation_input: float
var _tilt_input: float 


var _mouse_rotation: Vector3


@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER: Node3D



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hide mouse cursor

func _unhandled_input(event): # Built-in function. Fires evtime mouse moves
	# Check if the event is mouse moving
	# AND also checks if our mouse is in capture mode
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input == true:
		_rotation_input = -event.relative.x
		_tilt_input = -event.relative.y



func _update_camera(delta):
	
	# Rotate camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_mouse_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	_rotation_input = 0.0
	_tilt_input = 0.0



func _physics_process(delta):
	_update_camera(delta)
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
