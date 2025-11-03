extends Control


class_name SettingMenu


func set_visibility(_in_visible: bool) -> void:
	visible = _in_visible
	if SceneManagerAutoload.current_scene:
		if SceneManagerAutoload.current_scene is SceneBase:
			%RETRY.visible = SceneManagerAutoload.current_scene.show_ingame_ui


func _ready() -> void:
	%RESUME.pressed.connect(_on_resume_button_pressed)
	%RETRY.pressed.connect(func() -> void:
		SceneManagerAutoload.load_scene(SceneMapping.SceneType.MAIN_MENU)
		SceneManagerAutoload.pause_game(false)
	)


func _on_resume_button_pressed() -> void:
	SceneManagerAutoload.pause_game(false)
