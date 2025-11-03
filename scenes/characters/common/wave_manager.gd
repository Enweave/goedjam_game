extends Node3D


@export var wave_delay_length: float = 10.0

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

func _on_spawn_timer_timeout() -> void:
	if spawned_characters.size() == 0:
		PlayerStateAutoload.increase_wave()
		print_debug("Wave ", PlayerStateAutoload.current_wave, " starting.")
		for spawner in spawners:
			var _instance: CharacterWithHealth = spawner.spawn_enemy(PlayerStateAutoload.current_wave)
			spawned_characters.append(_instance)
			_instance.OnCharacterDied.connect(_on_spawned_character_death)
		PlayerStateAutoload.notify_wave_started()
	else:
		print_debug("Wave cannot start yet, [%d] still alive. " % spawned_characters.size())


func _on_spawned_character_death(in_character: CharacterWithHealth) -> void:
	spawned_characters.erase(in_character)
	PlayerStateAutoload.enemies_killed += 1
