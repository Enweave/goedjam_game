extends Node3D


class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = []


func spawn_enemy(_wave_number: int) -> CharacterWithHealth:
	if enemy_scenes.size() == 0:
		return null

	var random_index: int = randi() % enemy_scenes.size()
	var enemy_scene: PackedScene = enemy_scenes[random_index]
	var enemy_instance: CharacterWithHealth = enemy_scene.instantiate()



	var spawn_offset: Vector3 = Vector3.ZERO
	var max_attempts: int = 10
	var attempt: int = 0


	# store collision presets
	var original_collision_layer: int = enemy_instance.collision_layer
	var original_collision_mask: int = enemy_instance.collision_mask

	SceneManagerAutoload.get_current_scene().add_child(enemy_instance)

	while attempt < max_attempts:
		spawn_offset = Vector3(randf_range(-5.0, 5.0), 0, randf_range(-5.0, 5.0))
		var test_position: Vector3 = self.global_position + spawn_offset
		var space_state: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(test_position + Vector3.UP * 5.0, test_position + Vector3.DOWN * 5.0)
		space_state.collide_with_bodies = true

		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(space_state)
		if result:
			enemy_instance.global_position = result.position
			break
		attempt += 1

	enemy_instance.global_position = self.global_position

	# restore collision presets
	enemy_instance.collision_layer = original_collision_layer
	enemy_instance.collision_mask = original_collision_mask

	return enemy_instance

