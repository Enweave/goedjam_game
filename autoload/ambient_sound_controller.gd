extends Node


class_name AmbientSoundController

const FADE_TIME_SEC: float = 0.2
const LOW_VOLUME_DB: float = -50.0
var current_fade_time_sec: float = FADE_TIME_SEC

var current_player: AudioStreamPlayer = null
var new_player: AudioStreamPlayer = null

var scene_manager: SceneManager = SceneManagerAutoload

var tween: Tween = null
var _last_played_stream: AudioStream = null


func _make_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = SoundConstants.AMBIENCE_BUS_NAME
	player.volume_db = LOW_VOLUME_DB
	call_deferred("add_child", player)
	return player


func _ready() -> void:
	current_fade_time_sec = FADE_TIME_SEC
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)

	current_player = _make_player()
	new_player = _make_player()

	await get_tree().create_timer(0.5).timeout

	scene_manager.OnSceneChanged.connect(_on_scene_changed)


func _on_scene_changed(_in_scene: SceneBase) -> void:
	fade_out()


func play_stream(in_stream: AudioStream) -> void:
	if _last_played_stream == in_stream:
		return

	new_player.stream = in_stream
	new_player.play()

	if tween:
		tween.stop()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(current_player, "volume_db", LOW_VOLUME_DB, current_fade_time_sec)
	tween.tween_property(new_player, "volume_db", 0.0, current_fade_time_sec)
	tween.finished.connect(_on_fade_complete)


func _on_fade_complete() -> void:
	var temp: AudioStreamPlayer = current_player
	current_player = new_player
	new_player = temp


func fade_out() -> void:
	_last_played_stream = null

	if tween:
		tween.stop()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(current_player, "volume_db", LOW_VOLUME_DB, current_fade_time_sec)
	tween.tween_property(new_player, "volume_db", LOW_VOLUME_DB, current_fade_time_sec)
	tween.finished.connect(_on_stop_fade_complete)


func _on_stop_fade_complete() -> void:
	current_player.stop()
	new_player.stop()

	current_player.stream = null
	new_player.stream = null
