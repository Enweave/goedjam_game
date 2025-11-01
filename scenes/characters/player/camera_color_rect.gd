extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene_manager : SceneManager = SceneManagerAutoload
	material.set_shader_parameter("tex", scene_manager.viewport.get_texture())
