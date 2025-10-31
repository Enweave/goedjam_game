extends Node
class_name SceneBase

var scene_manager: SceneManager
@export var show_phone: bool = true

func _ready() -> void:
	scene_manager = SceneManagerAutoload
	scene_manager.set_current_scene(self)
