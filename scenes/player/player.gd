extends CharacterBody3D

var _mouse_input: bool = false # is the mouse moving?
var _rotation_input: float
var _tilt_input: float 


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hide mouse cursor

func _unhandled_input(event): # Built-in function. Fires evtime mouse moves
	# Check if the event is mouse moving
	# AND also checks if our mouse is in capture mode
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input == true:
		_rotation_input = -event.relative.x
		_tilt_input = -event.relative.y
	
	print(Vector2(_rotation_input, _tilt_input))
	




func _physics_process(delta):
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
