extends FeatureBase


class_name WeaponBase

@export_group("Combat parameters")
@export var damage: float = 1
@export var windup_time: float = 0.1
@export var cooldown_time: float = 0.3
@export var full_auto: bool = false

@export var activation_cost: float = 0
@export var energy_max: float = 1
@export var reload_time: float = 1.0
@export var reload_type: FeatureBase.ReloadType = FeatureBase.ReloadType.SINGLE_CHARGE


var instigator: CharacterBase = null

func _process(_delta: float) -> void:
	super._process(_delta)

func _ready():
	super._ready()
	initialize(
		windup_time,
		cooldown_time,
		full_auto,
		activation_cost,
		energy_max,
		reload_time,
		reload_type
	)


static func damage_character(in_character: Node, in_damage: float) -> void:
	if in_character != null:
		if HealthComponent.FIELD_NAME in in_character:
			var health_component: HealthComponent = in_character[HealthComponent.FIELD_NAME]
			health_component.damage(in_damage)
