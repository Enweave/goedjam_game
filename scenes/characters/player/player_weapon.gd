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

signal ReloadStarted
signal ReloadFinished
signal AmmoChanged
signal GunUpgraded


func _ready() -> void:
	super._ready()
	player_controller = PlayerControllerAutoload
	_reload_timer = Timer.new()
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.timeout.connect(_on_reload_timer_timeout)
	await call_deferred("add_child", _reload_timer)
	_is_reloading = false

	player_controller.OnFeatureActivated.connect(fire)
	player_controller.OnFeatureDeactivated.connect(deactivate)

	self.CooldownPassed.connect(_on_cooldown_passed)
	self.Activation.connect(_on_activation)


func _on_cooldown_passed():
	if current_ammo <= 0:
		reload()

func _on_activation():
	current_ammo -= 1
	_fire()
	player_weapon_sprite_handle.fire()
	AmmoChanged.emit()


func _fire() -> void:
	# for number_of_projectiles_per_shot make raycats with with random spread within spread_angle_degrees
	# use weapon_range for the length of the raycast
	var origin: Vector3 = global_position
	var space_state := get_world_3d().direct_space_state
	var half_spread: float = deg_to_rad(spread_angle_degrees) * 0.5

	# Forward direction of this node (-Z in Godot)
	var base_dir: Vector3 = -global_transform.basis.z
	var up: Vector3 = global_transform.basis.y
	var right: Vector3 = global_transform.basis.x

	for i in range(number_of_projectiles_per_shot):
		var yaw_offset: float = randf_range(-half_spread, half_spread)
		var pitch_offset: float = randf_range(-half_spread, half_spread)

		# Rotate base_dir by yaw (around up) and pitch (around right)
		var rot := Basis(up, yaw_offset) * Basis(right, pitch_offset)
		var dir: Vector3 = (rot * base_dir).normalized()

		var to: Vector3 = origin + dir * weapon_range

		var query := PhysicsRayQueryParameters3D.create(origin, to, 0b00000000_00000000_00000000_00000001)
		query.collide_with_bodies = true
		query.collide_with_areas = true

		var exclude := []
		exclude.append(owner.get_rid())
		query.exclude = exclude

		var hit := space_state.intersect_ray(query)

		if hit.size() > 0:
			var body = hit.get("collider")
			if HealthComponent.FIELD_NAME in body:
				var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
				health_component.damage(damage)


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
	GunUpgraded.emit()


func set_magazine_size(size: int) -> void:
	magazine_size = size
	AmmoChanged.emit()
	if current_ammo > magazine_size:
		current_ammo = magazine_size


func reload() -> void:
	if _is_reloading:
		return
	lock()
	if reload_sfx_player != null:
		reload_sfx_player.play_random_sfx()
	player_weapon_sprite_handle.reload()
	_is_reloading = true
	ReloadStarted.emit()
	_reload_timer.start()


func _on_reload_timer_timeout() -> void:
	current_ammo = magazine_size
	_is_reloading = false
	unlock()
	player_weapon_sprite_handle.idle()
	ReloadFinished.emit()
