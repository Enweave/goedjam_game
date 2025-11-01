extends CharacterWithHealth


class_name Player

@onready var player_camera: Node3D = %PlayerCamera


func _ready():
	character_controller = PlayerControllerAutoload
	character_controller.OnControlModeChanged.connect(_on_control_mode_changed)
	_on_control_mode_changed(character_controller.current_control_method)
	super._ready()


func _on_control_mode_changed(new_mode: PlayerController.ControlMethods):
	match new_mode:
		PlayerController.ControlMethods.KEYBOARD_AND_MOUSE:
			_aim_update_method = Callable(self, "_aim_update_from_mouse")
		PlayerController.ControlMethods.GAMEPAD:
			_aim_update_method = Callable(self, "_aim_update_to_controller_aim_direction")
		_:
			_aim_update_method = Callable(self, "_empty")


func _update_controller_aim_rotation_from_mouse():
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin = player_camera.project_ray_origin(mouse_position)
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + player_camera.project_ray_normal(mouse_position) * 2000
	)

	var hit_result: Dictionary = _wordlspace.intersect_ray(ray)

	if hit_result:
		character_controller.current_target_position = hit_result.position


func _aim_update_from_mouse(delta):
	_update_controller_aim_rotation_from_mouse()
	_aim_update_to_controller_target(delta)


func _on_death() -> void:
	set_movement_enabled(false)
	print_debug("PLAYER DEAD!")
