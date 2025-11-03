extends Node3D
class_name ProjectileBase

const HALF_PI: float = PI / 2

enum MovementMode {
	LINEAR,
	BALLISTIC,
	HOMING
}
@export var movement_mode: MovementMode = MovementMode.LINEAR

@export_range(0., 1.) var gravity_multiplier: float = 1
@export var orient_to_motion: bool = true
@export var lifetime: float = 0.5
@export var speed: float = 10
@export var pierce: bool = false

var _control_direction: Vector3 = Vector3.ZERO
var _lifetime_timer: Timer
var _alive: bool             = false
var _gravity: float          = ProjectSettings.get_setting("physics/3d/default_gravity") as float
var _instigator: Node3D      = null
var _weapon: RangedWeapon      = null
var _velocity: Vector3        = Vector3.ZERO

@onready var damage_area: Area3D = %DamageArea


var _final_gravity: float = 0


func _ready() -> void:
	damage_area.body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node) -> void:
	if !_alive:
		return

	if _body == _instigator:
		return

	if _body and _weapon:
		if _body.is_queued_for_deletion():
			return
		WeaponBase.damage_character(_body, _weapon.damage)

	if !pierce:
		kill_projectile()


func launch(in_instigator: Node3D, in_weapon: WeaponBase) -> void:
	_final_gravity = _gravity * gravity_multiplier
	_weapon = in_weapon
	_control_direction = in_weapon.get_target_direction()
	_instigator = in_instigator
	_lifetime_timer = Timer.new()
	_lifetime_timer.wait_time = lifetime
	_lifetime_timer.one_shot = true
	_lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
	_lifetime_timer.autostart = true
	await (call_deferred('add_child', _lifetime_timer))
	_alive = true
	if movement_mode == MovementMode.BALLISTIC and _weapon.get_target_object() != null:
		var suggested_velovity: Vector3 = suggest_launch_velocity(global_position, _weapon.get_target_object().global_position, _final_gravity, speed)
		if suggested_velovity != Vector3.ZERO:
			_velocity = suggested_velovity
		else:
			_velocity = _control_direction.normalized() * speed
		return
	if movement_mode == MovementMode.BALLISTIC or movement_mode == MovementMode.LINEAR:
		_velocity = _control_direction.normalized() * speed
		return



func _process(delta: float) -> void:
	if _alive:
		match movement_mode:
			MovementMode.LINEAR:
				position += _velocity * delta
			MovementMode.BALLISTIC:
				_velocity.z += clamp(_final_gravity * delta, -Constants.TERMINAL_VELOCITY, Constants.TERMINAL_VELOCITY)
				position += _velocity * delta
			MovementMode.HOMING:
				if _weapon != null:
					if _weapon._target_object != null:
						var direction: Vector3 = _weapon.get_target_object().global_position - position
						direction = direction.normalized()
						position += direction * speed * delta


func kill_projectile() -> void:
	if !_alive:
		return
	_alive = false
	call_deferred("queue_free")

func _on_lifetime_timer_timeout() -> void:
	kill_projectile()


func suggest_launch_velocity(start_position: Vector3, target_position: Vector3, in_gravity: float, in_launch_velocity: float) -> Vector3:
	# based on https://en.wikipedia.org/wiki/Projectile_motion#Angle_required_to_hit_coordinate_.28x.2Cy.29
	# specifically, Angle θ required to hit coordinate (x, y)
	# θ = atan((v^2 ± sqrt(v^4 - g(gx^2 + 2yv^2))) / gx)

	var x: float = abs(target_position.x - start_position.x)
	var z: float = start_position.z - target_position.z

	var v4: float = pow(in_launch_velocity, 4)
	var v2: float = pow(in_launch_velocity, 2)
	var gx2: float = in_gravity * pow(x, 2)
	var yv2: float = 2. * z * pow(in_launch_velocity, 2)

	var sqrt_value: float = sqrt(v4 - in_gravity * (gx2 + yv2))

	var theta2: float = atan((v2 + sqrt_value) / (in_gravity * x))
	var theta1: float = atan((v2 - sqrt_value) / (in_gravity * x))


	var theta: float = 0
	if theta1 > 0 and theta1 < HALF_PI:
		theta = theta1
	elif theta2 > 0 and theta2 < HALF_PI:
		theta = theta2
	else:
		return Vector3.ZERO

	var velocity_x: float = in_launch_velocity * cos(theta)
	var velocity_y: float = in_launch_velocity * sin(theta)

	if target_position.x < start_position.x:
			velocity_x = -velocity_x

	return Vector3(velocity_x,0, -velocity_y)
