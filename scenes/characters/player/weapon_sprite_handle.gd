extends Node3D

var sprite: AnimatedSprite3D
var character: CharacterWithHealth
var _initial_transform_location: Vector3

const DIRECTION_SUFFIX : String = "_back"

enum AnimationState {
	IDLE,
	FIRE,
	RELOAD
}

var ANIMATION_NAMES: Dictionary = {
	AnimationState.IDLE: "default",
	AnimationState.FIRE: "fire",
	AnimationState.RELOAD: "reload"
}

func _ready() -> void:
	_initial_transform_location = self.transform.origin

	var children: Array[Node] = get_children()
	for child in children:
		if child is AnimatedSprite3D:
			sprite = child as AnimatedSprite3D
			break

	if sprite == null:
		push_error("PlayerWeaponSprite requires an AnimatedSprite3D child node.")
		return


	character = get_parent() as CharacterWithHealth
	if character == null:
		push_error("PlayerWeaponSprite must be a child of a CharacterWithHealth node.")
		return

	sprite.play(ANIMATION_NAMES[AnimationState.IDLE])

func _process(_delta: float) -> void:
	if character == null or sprite == null:
		return

	var _vec: Vector3 = Vector3.RIGHT

	if character.character_controller.aiming_direction.x > 0:
		sprite.flip_h = false
	elif character.character_controller.aiming_direction.x < 0:
		sprite.flip_h = true
		_vec = Vector3.LEFT

	self.set_quaternion(Quaternion(
		_vec,
		Vector3(
			character.character_controller.aiming_direction.x,
			0,
			character.character_controller.aiming_direction.y
		)
	))

	if character.character_controller.aiming_direction.y < 0:
		self.transform.origin = Vector3(0, -0.35, 0.45)
	else:
		self.transform.origin = _initial_transform_location
