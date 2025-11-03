extends Node3D


@export var wave_delay_length: float = 5.0

var spawners: Array[EnemySpawner] = []
var spawned_characters: Array[CharacterWithHealth] = []

func _ready() -> void:
	for spawner in get_tree().get_nodes_in_group("EnemySpawners"):
		spawners.append(spawner)

	var spawn_timer: Timer = Timer.new()
	spawn_timer.wait_time = wave_delay_length
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	await get_tree().create_timer(1.0).timeout

	SceneManagerAutoload.get_current_scene().call_deferred("add_child", spawn_timer)
	_on_spawn_timer_timeout()


func get_number_to_spawn(_wave_number: int) -> int:
	var base_number: int = 1
	var scaling_factor: float = 1.3
	var calculated_number: int = int(base_number * pow(scaling_factor, _wave_number - 1))
	if calculated_number > 20:
		return 20
	return calculated_number

func _on_spawn_timer_timeout() -> void:
	if spawned_characters.size() == 0:
		PlayerStateAutoload.increase_wave()
		for spawner in spawners:
			for i in get_number_to_spawn(PlayerStateAutoload.current_wave):
				var _instance: CharacterWithHealth
				_instance = await spawner.spawn_enemy(PlayerStateAutoload.current_wave)
				spawned_characters.append(_instance)
				_instance.OnCharacterDied.connect(_on_spawned_character_death)
		PlayerStateAutoload.notify_wave_started()
		PlayerStateAutoload.current_player_character.health_component.heal(5.)


	else:
		print_debug("Wave cannot start yet, [%d] still alive. " % spawned_characters.size())


func _on_spawned_character_death(in_character: CharacterWithHealth) -> void:
	spawned_characters.erase(in_character)
	PlayerStateAutoload.enemies_killed += 1
