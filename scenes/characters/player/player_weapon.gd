extends WeaponBase


class_name PlayerWeapon

@export_group("Shotgun parameters")
@export var player_weapon_sprite_handle: PlayerWeaponSpriteHandle = null
@export var number_of_projectiles_per_shot: int = 2
@export var spread_angle_degrees: float = 2.0
@export var weapon_range: float = 300.0


var player_controller: PlayerController = null

var TracerScene : PackedScene
var scene_manager: SceneManager = SceneManagerAutoload


var tracer_pool: Array[Tracer] = []
var tracer_pool_size: int = 20

func _ready() -> void:
	super._ready()
	TracerScene = preload("res://scenes/visuals/tracer.tscn")
	player_controller = PlayerControllerAutoload


	player_controller.OnFeatureActivated.connect(activate)
	player_controller.OnFeatureDeactivated.connect(deactivate)
	player_controller.OnReloadRequested.connect(reload)
	player_controller.OnControlledCharacterDied.connect(_on_controlled_character_died)



	self.OnActivation.connect(_on_activation)
	self.OnReloadStarted.connect(func() -> void:
		PlayerStateAutoload.notify_from_weapon(self)
		player_weapon_sprite_handle.reload()
	)
	self.OnReloadCompleted.connect(func() -> void:
		PlayerStateAutoload.notify_from_weapon(self)
		player_weapon_sprite_handle.idle()
	)

	self.OnRegenerationTick.connect(func() -> void:
		PlayerStateAutoload.notify_from_weapon(self)
	)

	PlayerStateAutoload.notify_from_weapon(self)


func _on_controlled_character_died() -> void:
	player_controller.OnFeatureActivated.disconnect(activate)
	player_controller.OnFeatureDeactivated.disconnect(deactivate)
	player_controller.OnReloadRequested.disconnect(reload)


func _on_activation():
	_fire()
	player_weapon_sprite_handle.fire()

func get_free_tracer_from_pool() -> Tracer:
	for tracer in tracer_pool:
		if not tracer.busy:
			return tracer
	return null

func can_add_tracer_to_pool() -> bool:
	return tracer_pool.size() < tracer_pool_size

func _fire() -> void:
	PlayerStateAutoload.notify_from_weapon(self)
	var origin: Vector3 = global_position
	var space_state := get_world_3d().direct_space_state
	var half_spread: float = deg_to_rad(spread_angle_degrees) * 0.5

	var base_dir: Vector3 = -global_transform.basis.z
	var up: Vector3 = global_transform.basis.y
	var right: Vector3 = global_transform.basis.x

	for i in range(number_of_projectiles_per_shot):
		var yaw_offset: float = randf_range(-half_spread, half_spread)
		var pitch_offset: float = randf_range(-half_spread, half_spread)

		var rot := Basis(up, yaw_offset) * Basis(right, pitch_offset)
		var dir: Vector3 = (rot * base_dir).normalized()

		var to: Vector3 = origin + dir * weapon_range

		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, to, Constants.COLLISION_MASK_PRESET)
		query.collide_with_bodies = true
		query.collide_with_areas = true

		var exclude := []
		exclude.append(owner.get_rid())
		query.exclude = exclude

		var hit := space_state.intersect_ray(query)

		var tracer_to: Vector3 = to
		if hit.size() > 0:
			tracer_to = hit.get("position")

		var tracer: Tracer = get_free_tracer_from_pool()
		var reused_tracer: bool = true
		if tracer == null and can_add_tracer_to_pool():
			reused_tracer = false
			tracer = TracerScene.instantiate()

		if tracer:
			var from: Vector3 = player_weapon_sprite_handle.get_hotspot_position()
			tracer.init(from, tracer_to)
			if reused_tracer:
				tracer.do_trace()
			else:
				tracer_pool.append(tracer)
				scene_manager.get_current_scene().add_child(tracer)

		if hit.size() > 0:
			var body = hit.get("collider")
			WeaponBase.damage_character(body, damage)

