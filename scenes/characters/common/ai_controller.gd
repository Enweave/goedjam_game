extends CharacterController


class_name AIController

var TRACKING_INTERVAL: float = 0.1

@export var nav_agent: NavigationAgent3D
var player_state: PlayerState

func _ready() -> void:
	super._ready()

	player_state = PlayerStateAutoload

	if player_state.current_player_character:
		current_target_node = player_state.current_player_character
		var tracking_timer: Timer = Timer.new()
		tracking_timer.wait_time = TRACKING_INTERVAL
		tracking_timer.one_shot = false
		tracking_timer.autostart = true
		tracking_timer.timeout.connect(track_target)
		self.call_deferred("add_child", tracking_timer)
	else:
		push_error("PlayerCharacter not found in PlayerStateAutoload.")


func track_target() -> void:
	if current_target_node:
		nav_agent.set_target_position(current_target_node.global_transform.origin)
		current_target_position = current_target_node.global_transform.origin
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		var direction_to_target: Vector3 = (next_path_position - self.global_position).normalized()
		movement_vector = Vector2(direction_to_target.x, direction_to_target.z)
	else:
		movement_vector = Vector2.ZERO
