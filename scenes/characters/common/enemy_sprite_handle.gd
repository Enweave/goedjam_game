extends Node3D

var sprite: AnimatedSprite3D
var character: CharacterWithHealth

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
