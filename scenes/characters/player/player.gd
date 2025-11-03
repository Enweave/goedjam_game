extends CharacterWithHealth


class_name Player

@onready var player_camera: Node3D = %PlayerCamera
@onready var invulnerability_time: float = 0.6
var _invulnerability_timer: Timer

signal InvulnerabilityEnded

func _ready():
	character_controller = PlayerControllerAutoload
	character_controller.OnControlModeChanged.connect(_on_control_mode_changed)
	_on_control_mode_changed(character_controller.current_control_method)
	super._ready()

	_invulnerability_timer = Timer.new()
	_invulnerability_timer.wait_time = invulnerability_time
	_invulnerability_timer.one_shot = true
	_invulnerability_timer.timeout.connect(_end_invulnerability)
	add_child(_invulnerability_timer)

	PlayerStateAutoload.set_current_player_character(self)
	health_component.OnDamage.connect(_on_player_damage)
	health_component.OnHeal.connect(func (_amount: float) -> void:
		PlayerStateAutoload.notify_from_health_component(health_component)
	)

	await get_tree().create_timer(1.0).timeout
	PlayerStateAutoload.notify_from_health_component(health_component)


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
		character_controller.aiming_direction = Vector2(
			hit_result.position.x - body_root.global_position.x,
			hit_result.position.z - body_root.global_position.z
		).normalized()


func _on_player_damage(_amount: float) -> void:
	if health_component.is_invulnerable:
		return
	health_component.is_invulnerable = true
	_invulnerability_timer.start()
	PlayerStateAutoload.notify_from_health_component(health_component)


func _end_invulnerability() -> void:
	InvulnerabilityEnded.emit()
	health_component.is_invulnerable = false


func _aim_update_from_mouse(delta):
	_update_controller_aim_rotation_from_mouse()
	_aim_update_to_controller_target(delta)


func _on_death() -> void:
	set_movement_enabled(false)
	character_controller.OnControlledCharacterDied.emit()
	PlayerStateAutoload.notify_player_died()
