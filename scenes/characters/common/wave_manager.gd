extends Node3D


@export var wave_delay_length: float = 5.0
@export_range(1, 9) var base_enemy_number: int = 1
@export_range(2, 20) var enemy_cap: int = 20


var spawners: Array[EnemySpawner] = []
var spawned_characters: Array[CharacterWithHealth] = []


func _ready() -> void:
	for spawner in get_tree().get_nodes_in_group("EnemySpawners"):
		spawners.append(spawner)

	if enemy_cap < base_enemy_number:
		enemy_cap = base_enemy_number + 1

	var spawn_timer: Timer = Timer.new()
	spawn_timer.wait_time = wave_delay_length
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	await get_tree().create_timer(1.0).timeout

	SceneManagerAutoload.get_current_scene().call_deferred("add_child", spawn_timer)
	_on_spawn_timer_timeout()


func get_number_to_spawn(_wave_number: int) -> int:
	var scaling_factor: float = 1.3
	var calculated_number: int = int(base_enemy_number * pow(scaling_factor, _wave_number - 1))
	if calculated_number > enemy_cap:
		return enemy_cap
	return calculated_number


func _on_spawn_timer_timeout() -> void:
	# check if there are any enabled spawners
	var any_enabled_spawners: bool = false
	for spawner in spawners:
		if spawner.enabled:
			any_enabled_spawners = true
			break

	if spawned_characters.size() == 0 and any_enabled_spawners:
		PlayerStateAutoload.increase_wave()
		for spawner in spawners:
			if spawner.enabled == false:
				continue
			for i in get_number_to_spawn(PlayerStateAutoload.current_wave):
				var _instance: CharacterWithHealth
				_instance = await spawner.spawn_enemy(PlayerStateAutoload.current_wave)
				_instance.OnCharacterDied.connect(_on_spawned_character_death)
				spawned_characters.append(_instance)

		PlayerStateAutoload.notify_wave_started()
		PlayerStateAutoload.current_player_character.health_component.heal(5.)
	else:
		print_debug("Wave cannot start yet, [%d] still alive. " % spawned_characters.size())


func _on_spawned_character_death(in_character: CharacterWithHealth) -> void:
	spawned_characters.erase(in_character)
	PlayerStateAutoload.enemies_killed += 1
