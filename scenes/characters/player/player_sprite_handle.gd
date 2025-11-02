extends Node3D

var sprite: AnimatedSprite3D
var character: Player
var anim_player: AnimationPlayer

const DIRECTION_SUFFIX : String = "_back"

enum AnimationState {
	STAND,
	WALK,
	DEATH
}

var ANIMATION_NAMES: Dictionary = {
	AnimationState.STAND: "stand",
	AnimationState.WALK: "walk",
	AnimationState.DEATH: "death"
}

func _ready() -> void:
	var children: Array[Node] = get_children()
	for child in children:
		if child is AnimatedSprite3D:
			sprite = child as AnimatedSprite3D
			break

	if sprite == null:
		push_error("EnemySpriteHandle requires an AnimatedSprite3D child node.")
		return

#	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.play(ANIMATION_NAMES[AnimationState.WALK])


	character = get_parent() as CharacterWithHealth
	if character == null:
		push_error("EnemySpriteHandle must be a child of a CharacterWithHealth node.")
		return


	var health_component: HealthComponent = character.health_component
	if health_component:
		health_component.OnDeath.connect(_on_character_death)

		anim_player = self.get_node_or_null("AnimationPlayer")
		if anim_player:
			health_component.OnDamage.connect(func (_amount: float) -> void:
				anim_player.play("default")
			)

			character.InvulnerabilityEnded.connect(func () -> void:
				anim_player.play("RESET")
			)

func _add_suffix() -> String:
	if character.character_controller.aiming_direction.y < 0:
		return DIRECTION_SUFFIX
	return ""

func _process(_delta: float) -> void:
	if character == null or sprite == null:
		return

	if character.character_controller.aiming_direction.x > 0:
		sprite.flip_h = false
	elif character.character_controller.aiming_direction.x < 0:
		sprite.flip_h = true

	if character.velocity.length() > 0.1:
		sprite.play(ANIMATION_NAMES[AnimationState.WALK] + _add_suffix())
	else:
		sprite.play(ANIMATION_NAMES[AnimationState.STAND] + _add_suffix())

func _on_character_death() -> void:
	sprite.play(ANIMATION_NAMES[AnimationState.DEATH])
