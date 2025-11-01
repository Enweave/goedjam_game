extends CharacterWithHealth


class_name EnemyBase


func _ready() -> void:
	character_controller = get_node_or_null("AIController")
	super._ready()
	_aim_update_method = Callable(self, "_aim_update_to_controller_target")
