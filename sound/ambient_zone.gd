extends Area3D

class_name AmbientZone
# An ambient sound zone that plays ambient sounds when the player enters the area.


var ambient_sound_controller: AmbientSoundController = AmbientSoundControllerAutoload
@export var stream: AudioStream = null
@export var collision_shape: CollisionShape3D
@export var fade_on_leave: bool = false

func _ready() -> void:
	if !stream and !collision_shape:
		push_error("AmbientZone requires an AudioStream and a CollisionShape3D to function properly.")
		return


	body_entered.connect(_on_body_entered)
	if fade_on_leave:
		body_exited.connect(_on_body_exited)



func _on_body_entered(body: Node) -> void:
	if body is Player:
		ambient_sound_controller.play_stream(stream)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		ambient_sound_controller.fade_out()