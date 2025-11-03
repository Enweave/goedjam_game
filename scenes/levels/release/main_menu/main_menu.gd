extends SceneBase

#i added this to play animated sprite on titlescreen. lord help me.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	%StartGameButton.pressed.connect(func() -> void:
		SceneManagerAutoload.load_scene(SceneMapping.SceneType.GAME)
	)
	#this line too. Call me coder ty.
	animated_sprite.play("default")
