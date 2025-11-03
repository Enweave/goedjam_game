extends Node
class_name PlayerState

var current_player_character: Player = null
var ingame_ui: IngameUI = null
var current_wave: int = 0
var enemies_killed: int = 0

func set_ingame_ui(ui: IngameUI) -> void:
	ingame_ui = ui


func increase_wave() -> void:
	current_wave += 1

func notify_wave_started() -> void:
	if ingame_ui != null:
		ingame_ui.update_wave_display(current_wave)


func notify_from_weapon(in_weapon: PlayerWeapon) -> void:
	if ingame_ui != null:
		ingame_ui.update_weapon_display(in_weapon)


func notify_player_died() -> void:
	if ingame_ui != null:
		ingame_ui.game_over()

func notify_from_health_component(in_health_component: HealthComponent) -> void:
	if ingame_ui != null:
		ingame_ui.update_health_display(in_health_component)


func set_current_player_character(player_character: Player) -> void:
	current_player_character = player_character


func reset():
	current_player_character = null
	current_wave = 0
	enemies_killed = 0
	if ingame_ui != null:
		ingame_ui.reset()

func _ready() -> void:
	reset()
