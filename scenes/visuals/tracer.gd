extends Node3D


class_name Tracer

@export var lifetime: float = 0.2
@export var start_width: float = 0.08
@export var color: Color = Color(1, 0.9, 0.6, 1.0)


var _in_origin: Vector3
var _in_to: Vector3

var timer : SceneTreeTimer

var beam: MeshInstance3D

func _ready() -> void:
	beam = %Beam
	# Place tracer at origin and build a thin mesh towards "to"
	global_transform.origin = _in_origin
	var delta: Vector3 = _in_to - _in_origin
	var length := delta.length()
	if length < 0.01:
		queue_free()
		return

	var dir: Vector3 = delta / length
	var up := Vector3.UP
	if abs(dir.dot(up)) > 0.999:
		up = Vector3.RIGHT

	look_at(_in_origin + dir, up)

	var quad := QuadMesh.new()
	quad.size = Vector2(start_width, length)
	quad.orientation = 1
	beam.mesh = quad

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	beam.material_override = mat

	beam.transform.origin = Vector3(0, 0, -length * 0.5)
	beam.scale = Vector3(1, 1, 1)

	# Tween width (scale X/Y) and alpha down over lifetime
	var tween: Tween = create_tween()
	tween.tween_property(beam, "scale:x", 0.0, lifetime)
	tween.parallel().tween_property(beam, "scale:y", 0.0, lifetime)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, lifetime)
	timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_timer_timeout)


func init(in_origin: Vector3, in_to: Vector3) -> void:
	_in_origin = in_origin
	_in_to = in_to


func _on_timer_timeout() -> void:
	queue_free()
