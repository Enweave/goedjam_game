extends Node3D
class_name CharacterController

var movement_vector: Vector2 = Vector2.ZERO
var aiming_direction: Vector2 = Vector2.ZERO
var current_target_node: Node3D = null
var current_target_position: Vector3 = Vector3.ZERO

signal OnFeatureActivated
signal OnFeatureDeactivated

signal OnControlledCharacterDied


var current_control_method: ControlMethods = ControlMethods.AI_CONTROLLED

signal OnControlModeChanged(new_mode: ControlMethods)

enum ControlMethods {
	KEYBOARD_AND_MOUSE,
	GAMEPAD,
	AI_CONTROLLED
}

func normalize_and_clamp_vector2(vec: Vector2) -> Vector2:
	if vec.length() > 1.0:
		return vec.normalized()
	return vec

func _switch_control_method(to_method: ControlMethods) -> void:
	current_control_method = to_method
	OnControlModeChanged.emit(current_control_method)

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
