extends CharacterBase

class_name CharacterWithHealth

@export_group("Health")
@export var health_component: HealthComponent

func _ready() -> void:
	super._ready()
	if health_component == null:
		health_component = get_node_or_null("HealthComponent")

	if health_component:
		health_component.OnDamage.connect(_on_damage)
		health_component.OnDeath.connect(_on_death)


func _on_damage(_amount: float) -> void:
	print("%s took %f damage" % [self.name, _amount])


func _on_death() -> void:
	set_movement_enabled(false)
	self.call_deferred("queue_free")