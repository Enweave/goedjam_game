extends Node

class_name HealthComponent

@export var BASE_HEALTH: float = 10.0:
	set(value):
		BASE_HEALTH = value
		current_max_health = value
		current_health = min(current_health, current_max_health)

# health per second
@export var BASE_HEALTH_REGEN_RATE: float = 1.0:
	set(value):
		BASE_HEALTH_REGEN_RATE = value
		current_regen_rate = value

var current_max_health: float = 10.
var current_regen_rate: float = 0.0 # health per second

var current_health: float
var is_invulnerable: bool = false
var is_dead: bool		 = false

const FIELD_NAME: String = "HealthComponent"

signal OnDamage(amount: float)
signal OnHeal(amount: float)
signal OnDeath


func _ready() -> void:
	current_health = BASE_HEALTH
	current_max_health = BASE_HEALTH
	current_regen_rate = BASE_HEALTH_REGEN_RATE


func _process(delta: float) -> void:
	if current_regen_rate > 0.0 and not is_dead:
		heal(current_regen_rate * delta)


func update_max_health(value: float) -> void:
	current_max_health = value
	current_health = min(current_health, current_max_health)


func update_regen_rate(value: float) -> void:
	current_regen_rate = value


func reset_max_health() -> void:
	current_max_health = BASE_HEALTH
	current_health = min(current_health, current_max_health)


func reset_regen_rate() -> void:
	current_regen_rate = BASE_HEALTH_REGEN_RATE


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
	return current_health == current_max_health


func heal(amount: float) -> void:
	current_health = min(current_health + amount, current_max_health)
	OnHeal.emit(amount)
	
