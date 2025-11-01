extends CharacterController
class_name PlayerController

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
	Fire
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

	InputActions.Fire: "input_Fire",
}

func _process(_delta: float) -> void:
	movement_vector = normalize_and_clamp_vector2(Vector2(
		Input.get_axis(input_actions[InputActions.MoveLeft], input_actions[InputActions.MoveRight]),
		Input.get_axis(input_actions[InputActions.MoveUp], input_actions[InputActions.MoveDown])
	))

	aiming_direction = normalize_and_clamp_vector2(Vector2(
		Input.get_axis(input_actions[InputActions.AimLeft], input_actions[InputActions.AimRight]),
		Input.get_axis(input_actions[InputActions.AimUp], input_actions[InputActions.AimDown])
	))


	if Input.is_action_just_pressed(input_actions[InputActions.Fire]):
		OnFeatureActivated.emit()

	if Input.is_action_just_released(input_actions[InputActions.Fire]):
		OnFeatureDeactivated.emit()
		

func _unhandled_input(event):
	if event is InputEventKey:
		_switch_control_method(ControlMethods.KEYBOARD_AND_MOUSE)
		if event.is_action_pressed(input_actions[InputActions.Pause]):
			SceneManagerAutoload.handle_input_pause()

	if event is InputEventJoypadButton:
		_switch_control_method(ControlMethods.GAMEPAD)
		if event.is_action_pressed(input_actions[InputActions.Pause]):
			SceneManagerAutoload.handle_input_pause()
