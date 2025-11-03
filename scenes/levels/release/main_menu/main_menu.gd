extends SceneBase


func _ready() -> void:
	super._ready()
	%StartGameButton.pressed.connect(func() -> void:
		SceneManagerAutoload.load_scene(SceneMapping.SceneType.GAME)
	)
