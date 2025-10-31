extends Node3D

var root: Node3D
var MAX_TARGET_DISTANCE: float = 2.0

@export_range(0.0, 1.0, 0.01) var shake_intensity: float = 0.25
@export_range(0.01, 3.0, 0.01) var shake_duration: float = 0.5

@onready var camera: Camera3D = %PlayerCamera

var is_shaking: bool = false
var rng = RandomNumberGenerator.new()
var shake_start_time: float = 0


func _ready():
	randomize()
	root = get_parent()
	self.global_rotation.y = 0


func _process(_delta):
	var root_position: Vector3 = root.global_position
	var lerp_weight: float = root_position.distance_to(self.global_position) / MAX_TARGET_DISTANCE
	lerp_weight = clamp(lerp_weight, 0, 1)
	var new_pos: Vector3 = self.global_position.lerp(root_position, lerp_weight)

	if is_shaking:
		var time_passed: float = Time.get_ticks_msec() - shake_start_time
		var duration_ms: float = shake_duration * 1000.0
		var decreaser: float = (duration_ms - time_passed) / duration_ms
		var multiplier: float = (shake_intensity / 5.0) * decreaser

		camera.h_offset = rng.randf_range(-1.0, 1.0) * multiplier
		camera.v_offset = rng.randf_range(-1.0, 1.0) * multiplier

		if decreaser < 0.0:
			camera.h_offset = 0.0
			camera.v_offset = 0.0
			is_shaking = false

	self.global_position = new_pos


func shake():
	shake_start_time = Time.get_ticks_msec()
	is_shaking = true
