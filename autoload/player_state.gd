extends Node
class_name PlayerState

var current_player_character: Player = null
var ingame_ui: IngameUI = null


func set_ingame_ui(ui: IngameUI) -> void:
	ingame_ui = ui


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
	if ingame_ui != null:
		ingame_ui.reset()

func _ready() -> void:
	reset()
