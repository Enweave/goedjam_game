extends Node3D
class_name FeatureBase

enum ReloadType {
	SINGLE_CHARGE,
	FULL_MAGAZINE,
	REGENERATION
}

enum FeatureState {
	READY,
	WINDING_UP,
	COOLDOWN,
	RELOADING,
}

enum InitializationState {
	NOT_INITIALIZED,
	INITIALIZING,
	INITIALIZED
}

var _feature_state: FeatureState = FeatureState.READY
var _initialization_state: InitializationState = InitializationState.NOT_INITIALIZED
var _disabled: bool = false


var _cooldown_time: float  = 0.3
var _wind_up_time: float   = 0.1
var _wind_up_timer: Timer
var _cooldown_timer: Timer

var _auto_reactivate: bool = false
var _trigger_down: bool    = false

const REGENERATION_TIMESTEP: float = 0.1

var _activation_cost : float = 1
var _current_energy: float = 10
var _energy_max: float = 10
var _reload_amount: float = 1
var _reload_time: float = 1.0
var _reload_type: ReloadType = ReloadType.SINGLE_CHARGE

var _reload_timer: Timer = null

@export_group("Sound")
@export var sfx_player: RandomSFXPlayer = null
@export var no_ammo_sfx_player: RandomSFXPlayer = null
@export var reload_sfx_player: RandomSFXPlayer = null

signal OnWindupStarted
signal OnActivation
signal OnCooldownPassed
signal OnReloadStarted
signal OnReloadCompleted

var _target_object: Node3D     = null


func _ready():
	pass

func get_target_direction() -> Vector3:
	if _target_object == null:
		return Vector3.ZERO

	var _target_direction: Vector3 = _target_object.global_position - self.global_position
	_target_direction = _target_direction.normalized()

	return _target_direction


func set_target_object(in_object: Node3D) -> void:
	_target_object = in_object


func get_target_object() -> Node3D:
	return _target_object


func reload() -> bool:
	if _feature_state == FeatureState.RELOADING or \
		_current_energy >= _energy_max or \
		_disabled:
		return false

	_feature_state = FeatureState.RELOADING
	_reload_timer.start()
	OnReloadStarted.emit()

	return true


func activate() -> bool:
	_trigger_down = true
	if _initialization_state != InitializationState.INITIALIZED or \
		_feature_state != FeatureState.READY \
		or _disabled:
		return false

	if _has_enough_energy():
		_activate()
		if _reload_type == ReloadType.REGENERATION and _reload_timer.is_stopped():
			_reload_timer.start()
		return true

	else:
		if no_ammo_sfx_player != null:
			no_ammo_sfx_player.play_random_sound()
		if _reload_type != ReloadType.REGENERATION:
			reload()

	return false


func disable_feature() -> void:
	_disabled = true


func enable_feature() -> void:
	_disabled = false


func deactivate() -> void:
	_trigger_down = false


func reset() -> void:
	_wind_up_timer.stop()
	_cooldown_timer.stop()
	_reload_timer.stop()
	_feature_state = FeatureState.READY


func _set_up_reload():
	match _reload_type:
		ReloadType.SINGLE_CHARGE:
			_reload_amount = _activation_cost
			_reload_timer.wait_time = _reload_time
			_reload_timer.one_shot = true
		ReloadType.FULL_MAGAZINE:
			_reload_amount = _energy_max
			_reload_timer.wait_time = _reload_time
			_reload_timer.one_shot = true
		ReloadType.REGENERATION:
			_reload_amount = _energy_max / _reload_time / REGENERATION_TIMESTEP
			_reload_timer.wait_time = REGENERATION_TIMESTEP
			_reload_timer.one_shot = false


func initialize(
		in_wind_up_time: float,
		in_cooldown_time: float,
		in_auto_reactivate: bool,
		in_activation_cost: float = 1,
		in_energy_max: float = 10,
		in_reload_time: float = 1.0,
		in_reload_type: ReloadType = ReloadType.SINGLE_CHARGE
	) -> void:
	if _initialization_state == InitializationState.NOT_INITIALIZED:
		_initialization_state = InitializationState.INITIALIZING
		_wind_up_timer = Timer.new()

		_wind_up_time = in_wind_up_time
		if in_wind_up_time > 0:
			_wind_up_timer.wait_time = in_wind_up_time

		_wind_up_timer.one_shot = true
		_wind_up_timer.timeout.connect(_on_wind_up_timer_timeout)

		_cooldown_timer = Timer.new()

		_cooldown_time = in_cooldown_time
		if in_cooldown_time > 0:
			_cooldown_timer.wait_time = in_cooldown_time

		_cooldown_timer.one_shot = true
		_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

		_auto_reactivate = in_auto_reactivate

		_reload_timer = Timer.new()

		_activation_cost = in_activation_cost
		_energy_max = in_energy_max
		_current_energy = _energy_max
		_reload_type = in_reload_type
		_reload_time = in_reload_time

		_set_up_reload()
		_reload_timer.timeout.connect(_on_reload_timer_timeout)

		await call_deferred("add_child", _wind_up_timer)
		await call_deferred("add_child", _cooldown_timer)
		await call_deferred("add_child", _reload_timer)

		_initialization_state = InitializationState.INITIALIZED

func _on_reload_timer_timeout() -> void:
	_current_energy += _reload_amount
	match _reload_type:
		ReloadType.REGENERATION:
			if _reload_amount > 0:
				if _current_energy >= _energy_max:
					_current_energy = _energy_max
					_reload_timer.stop()
					OnReloadCompleted.emit()
		ReloadType.FULL_MAGAZINE:
			if _current_energy > _energy_max:
				_current_energy = _energy_max
			OnReloadCompleted.emit()
			if _trigger_down and _auto_reactivate:
				activate()
		ReloadType.SINGLE_CHARGE:
			if _feature_state == FeatureState.RELOADING:
				_feature_state = FeatureState.READY
			OnReloadCompleted.emit()

			if _trigger_down:
				activate()
			else:
				reload()

	if reload_sfx_player != null:
		reload_sfx_player.play_random_sound()


func _has_enough_energy() -> bool:
	return _current_energy >= _activation_cost


func _activate() -> void:
	_current_energy -= _activation_cost
	if _wind_up_time > 0:
		_wind_up_timer.start()
		OnWindupStarted.emit()
		_feature_state = FeatureState.WINDING_UP
	else:
		_on_wind_up_timer_timeout()


func _on_wind_up_timer_timeout() -> void:
	_feature_state = FeatureState.COOLDOWN
	OnActivation.emit()
	if sfx_player != null:
		sfx_player.play_random_sound()
	if _cooldown_time > 0:
		_cooldown_timer.start()
	else:
		_on_cooldown_timer_timeout()


func _on_cooldown_timer_timeout() -> void:
	OnCooldownPassed.emit()
	_feature_state = FeatureState.READY

	if _auto_reactivate and _trigger_down:
		activate()


func _process(_delta: float) -> void:
	pass