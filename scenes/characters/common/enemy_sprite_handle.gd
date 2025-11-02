extends Node3D


class_name EnemySpriteHandle

var sprite: AnimatedSprite3D
var character: CharacterWithHealth
var _attack_in_progress: bool = false

@export_category('animation')
@export var attack_offset: float = 0.15
@export var attack_duration: float = 0.2
@export var attack_offset_z: float = 0.15

enum AnimationState {
	MOVE,
	ATTACK,
	DEATH
}

var ANIMATION_NAMES: Dictionary = {
	AnimationState.MOVE: "default",
	AnimationState.ATTACK: "attack",
	AnimationState.DEATH: "death"
}


func _get_attack_offset() -> float:
	if sprite.flip_h:
		return attack_offset
	return -attack_offset


func do_melee_attack_animation() -> void:
	if _attack_in_progress:
		return

	if character:
		_attack_in_progress = true
		# tween sprite position towards attack offset and back
		var original_position: Vector3 = sprite.position
		var attack_position: Vector3 = original_position + Vector3(_get_attack_offset(), 0, -attack_offset_z)
		var tween: Tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, 'position', attack_position, attack_duration)
		tween.tween_property(sprite, 'position', original_position, attack_duration)
		tween.finished.connect(func() -> void:
			_attack_in_progress = false
		)


func _ready() -> void:
	# get first child and check if it's a Sprite3D
	var children: Array[Node] = get_children()
	for child in children:
		if child is AnimatedSprite3D:
			sprite = child as AnimatedSprite3D
			break

	if sprite == null:
		push_error("EnemySpriteHandle requires an AnimatedSprite3D child node.")
		return

#	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.play(ANIMATION_NAMES[AnimationState.MOVE])


	character = get_parent() as CharacterWithHealth
	if character == null:
		push_error("EnemySpriteHandle must be a child of a CharacterWithHealth node.")
		return

	var health_component: HealthComponent = character.health_component
	if health_component:
		health_component.OnDeath.connect(_on_character_death)

func _process(_delta: float) -> void:
	if character == null or sprite == null:
		return

	if character.velocity.x > 0:
		sprite.flip_h = true
	elif character.velocity.x < 0:
		sprite.flip_h = false

func _on_character_death() -> void:
	sprite.play(ANIMATION_NAMES[AnimationState.DEATH])
