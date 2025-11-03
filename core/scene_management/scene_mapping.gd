extends Node
class_name SceneMapping

enum SceneType {
	MAIN_MENU,
	GAME,
}


static func get_scene_path(in_scene: SceneType) -> String:
	match in_scene:
		SceneType.MAIN_MENU:
			return "res://scenes/levels/release/main_menu/main_menu.tscn"
		SceneType.GAME:
			return "res://scenes/levels/release/game.tscn"
		_:
			return ""
