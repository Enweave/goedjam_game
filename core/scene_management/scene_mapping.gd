extends Node
class_name SceneMapping

enum SceneType {
	MAIN_MENU,
	EXPOSITION,
	GAME,
	GAME_OVER,
	GAME_WIN,
}


static func get_scene_path(in_scene: SceneType) -> String:
	match in_scene:
		SceneType.MAIN_MENU:
			return "res://Scenes/MainMenu/main_menu.tscn"
		SceneType.EXPOSITION:
			return "res://Scenes/Exposition/exposition.tscn"
		SceneType.GAME:
			return "res://Scenes/Training/training.tscn"
		SceneType.GAME_OVER:
			return "res://Scenes/GameOver/game_over.tscn"
		SceneType.GAME_WIN:
			return "res://Scenes/GameWin/game_win.tscn"
		_:
			return ""
