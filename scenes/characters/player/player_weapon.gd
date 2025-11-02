extends WeaponBase


class_name PlayerWeapon

@export var player_weapon_sprite_handle: PlayerWeaponSpriteHandle = null
@export var magazine_size: int = 6
@export var no_ammo_sfx_player: RandomSFXPlayer = null
@export var reload_sfx_player: RandomSFXPlayer = null
@export var number_of_projectiles_per_shot: int = 2
@export var spread_angle_degrees: float = 2.0
@export var weapon_range: float = 300.0

var current_ammo: int = magazine_size
var reload_time: float = 1.0
var _is_reloading: bool = true
var _reload_timer: Timer

var player_controller: PlayerController = null

var TracerScene : PackedScene
var scene_manager: SceneManager = SceneManagerAutoload

func _ready() -> void:
	super._ready()
	TracerScene = preload("res://scenes/visuals/tracer.tscn")
	player_controller = PlayerControllerAutoload
	_reload_timer = Timer.new()
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.timeout.connect(_on_reload_timer_timeout)
	await call_deferred("add_child", _reload_timer)
	_is_reloading = false

	player_controller.OnFeatureActivated.connect(fire)
	player_controller.OnFeatureDeactivated.connect(deactivate)

	self.OnCooldownPassed.connect(_on_cooldown_passed)
	self.OnActivation.connect(_on_activation)

	PlayerStateAutoload.notify_from_weapon(self)


func _on_cooldown_passed():
	if current_ammo <= 0:
		reload()

func _on_activation():
	current_ammo -= 1
	_fire()
	player_weapon_sprite_handle.fire()


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

		var tracer: Tracer = TracerScene.instantiate()
		var from: Vector3 = player_weapon_sprite_handle.get_hotspot_position()
		if tracer and tracer.has_method("init"):
			tracer.init(from, tracer_to)
			scene_manager.get_current_scene().add_child(tracer)

		if hit.size() > 0:
			var body = hit.get("collider")
			WeaponBase.damage_character(body, damage)



func fire() -> void:
	if _is_reloading:
		return

	if current_ammo <= 0:
		if no_ammo_sfx_player != null:
			no_ammo_sfx_player.play_random_sfx()
		reload()

		return
	activate()


func set_number_of_projectiles_per_shot(count: int) -> void:
	number_of_projectiles_per_shot = count


func set_magazine_size(size: int) -> void:
	magazine_size = size
	if current_ammo > magazine_size:
		current_ammo = magazine_size


func reload() -> void:
	if _is_reloading:
		return
	lock()
	PlayerStateAutoload.notify_from_weapon(self)
	if reload_sfx_player != null:
		reload_sfx_player.play_random_sfx()
	player_weapon_sprite_handle.reload()
	_is_reloading = true
	_reload_timer.start()


func _on_reload_timer_timeout() -> void:
	current_ammo = magazine_size
	_is_reloading = false
	unlock()
	PlayerStateAutoload.notify_from_weapon(self)
	player_weapon_sprite_handle.idle()
