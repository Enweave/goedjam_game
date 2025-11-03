extends CharacterWithHealth

class_name EnemyBase

@export var DEATH_TIMEOUT_SECONDS: float = 1.0
var _death_queued: bool = false

func _ready() -> void:
	character_controller = get_node_or_null("AIController")
	super._ready()
	_aim_update_method = Callable(self, "_aim_update_to_controller_target")


func _on_death() -> void:
	if _death_queued:
		return
	character_controller.process_mode = Node.PROCESS_MODE_DISABLED
	_death_queued = true
	set_movement_enabled(false)
	self.collision_layer = 0
	self.collision_mask = 0

	velocity = Vector3.ZERO

	OnCharacterDied.emit(self)
	get_tree().create_timer(DEATH_TIMEOUT_SECONDS).timeout.connect(queue_free)