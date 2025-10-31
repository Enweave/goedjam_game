extends CharacterBase


const SPEED: float = 10.0
const ACCELERATION: float = 60.0

const JUMP_VELOCITY: float = 4.5

@onready var player_camera: Node3D = %PlayerCamera
@onready var body_root: Node3D = %BodyRoot
var _wordlspace: PhysicsDirectSpaceState3D


var input_controller: InputController = null
var _physics_process_method: Callable = Callable(self, "_empty")
var _aim_update_method: Callable = Callable(self, "_empty")

func _empty(_delta):
	pass

func _ready():
	super._ready()
	_wordlspace = get_world_3d().get_direct_space_state()
	input_controller = InputControllerAutoload
	_physics_process_method = Callable(self, "_physics_process_implementation")
	input_controller.OnJumpPressed.connect(_on_jump_pressed)
	input_controller.OnModeChanged.connect(_on_input_mode_changed)


func _on_input_mode_changed(new_mode: InputController.InputMethods):
	match new_mode:
		InputController.InputMethods.KEYBOARD_AND_MOUSE:
			_aim_update_method = Callable(self, "_aim_update_from_mouse")
		InputController.InputMethods.GAMEPAD:
			_aim_update_method = Callable(self, "_aim_update_from_gamepad")

func _on_jump_pressed():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _update_controller_aim_rotation_from_mouse():
	var aim_direction: Quaternion = body_root.global_transform.basis.get_rotation_quaternion()

	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin = player_camera.project_ray_origin(mouse_position)
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + player_camera.project_ray_normal(mouse_position) * 2000
	)

	var hit_result: Dictionary = _wordlspace.intersect_ray(ray)

	if hit_result:
		var _hit_position: Vector3 = hit_result.position
		_hit_position.y = body_root.global_position.y
		var _direction: Vector3 = body_root.global_transform.origin.direction_to(_hit_position)
		aim_direction = Quaternion(Vector3.FORWARD, _direction)

		body_root.set_quaternion(aim_direction)


func _aim_update_from_mouse(delta):
	_update_controller_aim_rotation_from_mouse()

func _aim_update_from_gamepad(delta):
	var aim_direction: Vector2 = input_controller.aiming_direction
	if aim_direction == Vector2.ZERO:
		return

	body_root.look_at(
		body_root.global_position + Vector3(aim_direction.x, 0, aim_direction.y),
		Vector3.UP
	)


func _physics_process_implementation(delta):
	var direction: Vector3 = Vector3(
		input_controller.movement_vector.x,
		0,
		input_controller.movement_vector.y
	)

	_aim_update_method.call(delta)

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, ACCELERATION * delta)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	_physics_process_method.call(delta)


	move_and_slide()
