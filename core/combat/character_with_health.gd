extends CharacterBase

class_name CharacterWithHealth

@export_group("Health")
@export var health_component: HealthComponent

signal OnCharacterDied(character: CharacterWithHealth)

func _ready() -> void:
	super._ready()
	if health_component == null:
		health_component = get_node_or_null("HealthComponent")

	if health_component:
		health_component.OnDamage.connect(_on_damage)
		health_component.OnDeath.connect(_on_death)


func _on_damage(_amount: float) -> void:
	pass


func _on_death() -> void:
	set_movement_enabled(false)
	character_controller.OnControlledCharacterDied.emit()
	OnCharacterDied.emit(self)
	self.call_deferred("queue_free")