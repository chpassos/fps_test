extends CharacterBody3D

# Captures mouse movement
var _mouse_input: bool = false # is the mouse moving?
var _rotation_input: float
var _tilt_input: float 

var _mouse_rotation: Vector3

# Handles and manages player rotation aligned with camera rotation
var _player_rotation: Vector3
var _camera_rotation: Vector3

var _is_crouching: bool = false

var _speed: float

@export var SPEED_DEFAULT: float = 5.0
@export var SPEED_CROUCH: float = 2.0
@export var SPEED_RUN: float = 8.0

@export var JUMP_VELOCITY: float = 4.5
@export_range(5, 10, 0.1) var CROUCH_SPEED: float = 7.0

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER: Node3D
@export var MOUSE_SENSITIVITY: float = 0.5

@export var ANIMATION_PLAYER: AnimationPlayer
@export var CROUCH_SHAPECAST: Node3D


func _ready():
	_speed = SPEED_DEFAULT
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hide mouse cursor
	
	CROUCH_SHAPECAST.add_exception($".")

func _crouching(state: bool):
	match state:
		true:
			ANIMATION_PLAYER.play("crouch", -1, CROUCH_SPEED)
			_set_movement_speed("crouching")
		false:
			ANIMATION_PLAYER.play("crouch", -1, -CROUCH_SPEED, true)
			_set_movement_speed("default")

func _set_movement_speed(state: String):
	match state:
		"default":
			_speed = SPEED_DEFAULT
		"crouching":
			_speed = SPEED_CROUCH
		"running":
			_speed = SPEED_RUN


func _input(event):
	if event.is_action_pressed("crouch") and is_on_floor() == true:
		_toggle_crouch()
	
	if event.is_action_pressed("run"):
		_set_movement_speed("running")
	elif event.is_action_released("run"):
		_set_movement_speed("default")



func _toggle_crouch():
	if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		_crouching(false)
	elif _is_crouching == false:
		_crouching(true)

func _on_animation_player_animation_started(anim_name):
	if anim_name == "crouch":
		_is_crouching = !_is_crouching







func _unhandled_input(event): # Built-in function. Fires evtime mouse moves
	# Check if the event IS ACTUALLY the mouse moving
	# AND also checks if our mouse is in capture mode
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	# If thats so, we change some variables!
	if _mouse_input == true:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY



func _update_camera(delta):
	
	# Rotate camera using euler rotation
	# In here, we begin capturing the values from the mouse movement input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	# Rotate the player
	# Then we handle other variables...
	## For the Y-axis rotation
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	
	## For the X-axis rotation
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	## CAMERA ROTATION HERE!
	### The basis part of the transform is responsible for the node's rotation and scale
	### The basis is a 3x3 matrix that encodes rotation and scaling
	### Also, from_euler creates the rotation for the other axis, not just X-axis
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	## Z-axis will always be 0
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	## PLAYER ROTATION HERE!
	### This line of code ensures that our player rotates with camera
	### Therefore, we can always walk forward, regardless of the camera rotation
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	# Reset the variables, so our camera does not keeps moving!
	_rotation_input = 0.0
	_tilt_input = 0.0







func _physics_process(delta):
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == false:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)

	move_and_slide()
