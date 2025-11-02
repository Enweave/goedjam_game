extends WeaponBase


class_name MeleeWeapon

@onready var sensor_area: Area3D = %SensorArea
@export var weapon_range : float = 1.0
var target_in_range: bool = false

signal OnTargetInRangeChanged()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	full_auto = true
	super._ready()

	# add a sphere shape to the sensor area
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = weapon_range
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = shape
	sensor_area.add_child(collision_shape)

	sensor_area.body_entered.connect(_on_sensor_area_body_entered)
	sensor_area.body_exited.connect(_on_sensor_area_body_exited)

func _on_sensor_area_body_entered(body: Node) -> void:
	if body == get_target_object():
		target_in_range = true
		OnTargetInRangeChanged.emit()

func _on_sensor_area_body_exited(body: Node) -> void:
	if body == get_target_object():
		target_in_range = false
		OnTargetInRangeChanged.emit()