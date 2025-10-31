extends CharacterBase


const SPEED: float = 10.0
const ACCELERATION: float = 60.0

const JUMP_VELOCITY: float = 4.5

var input_controller: InputController = null
var _physics_process_method: Callable = Callable(self, "_empty")

func _empty(_delta):
	pass

func _ready():
	super._ready()
	input_controller = InputControllerAutoload
	_physics_process_method = Callable(self, "_physics_process_implementation")
	input_controller.OnJumpPressed.connect(_on_jump_pressed)

func _on_jump_pressed():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _physics_process_implementation(delta):
	var direction: Vector3 = Vector3(
		input_controller.movement_direction.x,
		0,
		input_controller.movement_direction.y
	)

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
