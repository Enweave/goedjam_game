extends Node
class_name InputController

var current_character: CharacterBase = null

enum InputMethods {
	KeyboardMouse,
	Gamepad,
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

	InputActions.Inventory0: "input_Inventory0",
	InputActions.Inventory1: "input_Inventory1",
	InputActions.Inventory2: "input_Inventory2",
}


func set_current_character(character: CharacterBase = null) -> void:
	current_character = character


func _process(_delta: float) -> void:
	if current_character != null:
		pass
#		var direction_x: float = Input.get_axis(input_actions[InputActions.MoveLeft], input_actions[InputActions.MoveRight])
#		var direction_y: float = Input.get_axis(input_actions[InputActions.MoveUp], input_actions[InputActions.MoveDown])
#
#		current_character.set_control_direction(Vector2(direction_x, direction_y))
#
#		if Input.is_action_just_pressed(input_actions[InputActions.Jump]):
#			current_character.trigger_jump()
#
#		if Input.is_action_just_pressed(input_actions[InputActions.Fire]):
#			current_character.activate_current_feature()
#
#		if Input.is_action_just_released(input_actions[InputActions.Fire]):
#			current_character.deactivate_current_feature()
		



func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed(input_actions[InputActions.Pause]):
			SceneManagerAutoload.handle_input_pause()
			