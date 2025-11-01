extends Node
class_name PlayerState

var current_player_character: Player = null

func set_current_player_character(player_character: Player) -> void:
	current_player_character = player_character

func reset():
	current_player_character = null

func _ready() -> void:
	reset()