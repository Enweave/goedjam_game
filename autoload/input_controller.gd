extends Node
class_name InputController

var movement_vector: Vector2 = Vector2.ZERO
var aiming_direction: Vector2 = Vector2.ZERO

var current_input_method: InputMethods = InputMethods.KEYBOARD_AND_MOUSE

signal OnModeChanged(new_mode: InputMethods)

signal OnFirePressed
signal OnFireReleased

signal OnJumpPressed
signal OnJumpReleased


enum InputMethods {
	KEYBOARD_AND_MOUSE,
	GAMEPAD
}

enum InputActions {
	Pause,
	MoveUp,
	MoveDown,
	MoveLeft,
	MoveRight,
	AimLeft,
	AimRight,
	AimUp,
	AimDown,
	Jump,
	Fire,
	Inventory0,
	Inventory1,
	Inventory2,
}
	
var input_actions: Dictionary = {
	InputActions.Pause: "input_Pause",

	InputActions.MoveUp: "input_MoveUp",
	InputActions.MoveDown: "input_MoveDown",
	InputActions.MoveLeft: "input_MoveLeft",
	InputActions.MoveRight: "input_MoveRight",

	InputActions.AimUp: "input_AimUp",
	InputActions.AimDown: "input_AimDown",
	InputActions.AimLeft: "input_AimLeft",
	InputActions.AimRight: "input_AimRight",

	InputActions.Jump: "input_Jump",
	InputActions.Fire: "input_Fire",
}


func _switch_input_method(to_method: InputMethods) -> void:
	current_input_method = to_method
	OnModeChanged.emit(current_input_method)


func normalize_and_clamp_vector2(vec: Vector2) -> Vector2:
	if vec.length() > 1.0:
		return vec.normalized()
	return vec

func _process(_delta: float) -> void:

	movement_vector = normalize_and_clamp_vector2(Vector2(
		Input.get_axis(input_actions[InputActions.MoveLeft], input_actions[InputActions.MoveRight]),
		Input.get_axis(input_actions[InputActions.MoveUp], input_actions[InputActions.MoveDown])
	))

	aiming_direction = normalize_and_clamp_vector2(Vector2(
		Input.get_axis(input_actions[InputActions.AimLeft], input_actions[InputActions.AimRight]),
		Input.get_axis(input_actions[InputActions.AimUp], input_actions[InputActions.AimDown])
	))

	if Input.is_action_just_pressed(input_actions[InputActions.Jump]):
		OnJumpPressed.emit()

	if Input.is_action_just_released(input_actions[InputActions.Jump]):
		OnJumpReleased.emit()

	if Input.is_action_just_pressed(input_actions[InputActions.Fire]):
		OnFirePressed.emit()

	if Input.is_action_just_released(input_actions[InputActions.Fire]):
		OnFireReleased.emit()
		

func _unhandled_input(event):
	if event is InputEventKey:
		_switch_input_method(InputMethods.KEYBOARD_AND_MOUSE)
		if event.is_action_pressed(input_actions[InputActions.Pause]):
			SceneManagerAutoload.handle_input_pause()

	if event is InputEventJoypadButton:
		_switch_input_method(InputMethods.GAMEPAD)
		if event.is_action_pressed(input_actions[InputActions.Pause]):
			SceneManagerAutoload.handle_input_pause()
