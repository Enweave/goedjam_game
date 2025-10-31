extends Node

class_name HealthComponent

@export_group("Health")
@export var max_health: float = 10.

const FIELD_NAME: String = "health_component"

signal OnDamage(amount: float)
signal OnHeal(amount: float)
signal OnDeath

var current_health: float
var is_invulnerable: bool = false
var is_dead: bool		 = false


func _ready() -> void:
	current_health = max_health
	
func _init() -> void:
	current_health = max_health

func update_max_health(value: float) -> void:
	max_health = value
	current_health = min(current_health, max_health)

func damage(amount: float) -> bool:
	if is_invulnerable or is_dead:
		return false
	

	current_health -= amount #amount

	if current_health <= 0:
		is_dead = true
		OnDeath.emit()
	OnDamage.emit(amount)
	return true

func instakill() -> void:
	is_dead = true
	current_health = 0
	OnDeath.emit()

func is_full() -> bool:
	return current_health == max_health

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	OnHeal.emit(amount)
	
