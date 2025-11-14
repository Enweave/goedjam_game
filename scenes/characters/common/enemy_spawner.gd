extends Node3D


class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = []
@export var enabled: bool = true
@export_range(2., 50., 0.1) var spawn_radius: float = 10.0
@export_range(1, 10) var max_test_attempts: int = 5
var nav_agent: NavigationAgent3D = null


func _ready() -> void:
	nav_agent = NavigationAgent3D.new()
	nav_agent.radius = 0.5
	nav_agent.height = 2.0
	nav_agent.target_desired_distance = 0.1
	self.call_deferred('add_child', nav_agent)


func get_random_point_navigatable_space(in_radius: float) -> Vector3:
	if nav_agent == null:
		return self.global_position

	var random_direction: Vector3 = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized()

	var random_distance: float = randf_range(0.0, in_radius)
	var target_position: Vector3 = self.global_position + random_direction * random_distance


	nav_agent.set_target_position(target_position)
	var next_path_position: Vector3 = nav_agent.get_next_path_position()

	return next_path_position


func test_collision_and_get_position(test_position: Vector3) -> Vector3:
	var spawn_offset: Vector3 = Vector3.ZERO
	var result_position: Vector3 = test_position
	var attempt: int = 0

	while attempt < max_test_attempts:
		attempt += 1
		spawn_offset = Vector3(randf_range(-3.0, 3.0), 0, randf_range(-3.0, 3.0))
		test_position = self.global_position + spawn_offset
		var space_state: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			self.global_position,
			test_position
		)
		space_state.collide_with_bodies = true

		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(space_state)
		if result:
			break
		result_position = test_position

	return result_position


func spawn_enemy(_wave_number: int) -> CharacterWithHealth:
	if enemy_scenes.size() == 0:
		return null

	var random_index: int = randi() % enemy_scenes.size()
	var enemy_scene: PackedScene = enemy_scenes[random_index]
	var enemy_instance: CharacterWithHealth = enemy_scene.instantiate()
	var spawn_position: Vector3 = Vector3.ZERO

	await SceneManagerAutoload.get_current_scene().call_deferred('add_child', enemy_instance)

	spawn_position = get_random_point_navigatable_space(spawn_radius)
	spawn_position = test_collision_and_get_position(spawn_position)

	await enemy_instance.ready

	enemy_instance.global_position = spawn_position

	return enemy_instance
