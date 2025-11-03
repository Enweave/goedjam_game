extends Node3D


class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = []


func spawn_enemy(_wave_number: int) -> CharacterWithHealth:
	if enemy_scenes.size() == 0:
		return null

	var random_index: int = randi() % enemy_scenes.size()
	var enemy_scene: PackedScene = enemy_scenes[random_index]
	var enemy_instance: CharacterWithHealth = enemy_scene.instantiate()

	SceneManagerAutoload.get_current_scene().add_child(enemy_instance)

	enemy_instance.global_position = self.global_position
	enemy_instance.global_rotation = self.global_rotation

	return enemy_instance