extends CharacterBody3D
class_name CharacterBase

var character_controller: CharacterController = null
var _physics_process_method: Callable = Callable(self, "_empty")
var _aim_update_method: Callable = Callable(self, "_empty")
var _wordlspace: PhysicsDirectSpaceState3D
var _aim_direction_quaternion: Quaternion

@onready var body_root: Node3D = %BodyRoot
@export_category("movement")
@export var BASE_MOVEMENT_SPEED: float = 10.0:
	set(value):
		BASE_MOVEMENT_SPEED = value
		_calculate_movement_stats()


var _movement_enabled: bool = true


func set_movement_enabled(enabled: bool) -> void:
	_movement_enabled = enabled
	if not _movement_enabled:
		_physics_process_method = Callable(self, "_empty")
	else:
		_physics_process_method = Callable(self, "_physics_process_implementation")


func _empty(_delta):
	pass


var movement_modifier: float = 0:
	set(value):
		movement_modifier = value
		_calculate_movement_stats()

var _calculated_movement_speed: float = 0
var _calculated_acceleration: float = 0


func _calculate_movement_stats() -> void:
	_calculated_movement_speed = BASE_MOVEMENT_SPEED + movement_modifier
	_calculated_acceleration = abs((BASE_MOVEMENT_SPEED + movement_modifier) * 6.0)


func get_movement_speed() -> float:
	return _calculated_movement_speed


func get_acceleration() -> float:
	return _calculated_acceleration


func _ready() -> void:
	if character_controller == null:
		print_debug("CharacterBase: character_controller is not assigned!")
		return

	_wordlspace = get_world_3d().get_direct_space_state()
	_calculate_movement_stats()
	set_movement_enabled(true)


func _physics_process_implementation(delta):
	var direction: Vector3 = Vector3(
		character_controller.movement_vector.x,
		0,
		character_controller.movement_vector.y
	)

	_aim_update_method.call(delta)

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * get_movement_speed(), get_acceleration() * delta)
		velocity.z = move_toward(velocity.z, direction.z * get_movement_speed(), get_acceleration() * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, get_acceleration() * delta)
		velocity.z = move_toward(velocity.z, 0, get_acceleration() * delta)


func _aim_update_to_controller_target(delta):
	var _hit_position: Vector3 = character_controller.current_target_position
	_hit_position.y = body_root.global_position.y
	var _direction: Vector3 = body_root.global_transform.origin.direction_to(_hit_position)
	_aim_direction_quaternion = Quaternion(Vector3.FORWARD, _direction)
	body_root.set_quaternion(_aim_direction_quaternion)


func _aim_update_to_controller_aim_direction(delta):
	if character_controller.aiming_direction == Vector2.ZERO:
		return

	body_root.look_at(
		body_root.global_position + Vector3(character_controller.aiming_direction.x, 0, character_controller.aiming_direction.y),
		Vector3.UP
	)

func _physics_process(delta):
	if not is_on_floor() and _movement_enabled:
		velocity += get_gravity() * delta

	_physics_process_method.call(delta)
	move_and_slide()