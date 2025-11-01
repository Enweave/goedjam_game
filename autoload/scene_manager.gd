extends Node
class_name SceneManager

const FADE_DURATION: float = 0.5
var current_scene: SceneBase
var viewport_container: SubViewportContainer
var viewport: SubViewport
var pause_menu: Control
var last_increment_index: int = 0

signal scene_changed(new_scene: SceneBase)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	viewport_container = SubViewportContainer.new()
	viewport_container.set_visible(false)
	viewport = SubViewport.new()
	await get_tree().get_root().call_deferred("add_child", viewport_container)
	await viewport_container.call_deferred("add_child", viewport)
	viewport_container.set_mouse_filter(Control.MOUSE_FILTER_STOP)
	viewport_container.focus_mode = Control.FOCUS_ALL

	var viewport_size: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	viewport.size = viewport_size
	viewport.audio_listener_enable_2d = true
	viewport.audio_listener_enable_3d = true
	viewport.handle_input_locally = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	get_tree().create_timer(0.3).timeout.connect(_on_ready_timeout)


#	var pause_menu_scene: PackedScene = preload("res://Scenes/Common/settings_menu.tscn")
#	pause_menu = pause_menu_scene.instantiate()
#	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
#	pause_menu.visible = false
#
#	await get_tree().get_root().call_deferred("add_child", pause_menu)



func _on_ready_timeout():
	viewport_container.set_visible(true)
	get_tree().get_root().move_child(viewport_container, 0)
	scene_changed.emit(current_scene)


func set_current_scene(in_scene: SceneBase) -> void:
	current_scene = in_scene
	current_scene.call_deferred("reparent", viewport, true)
	scene_changed.emit(current_scene)


func load_scene(scene_type: SceneMapping.SceneType) -> void:
	var scene_path: String = SceneMapping.get_scene_path(scene_type)
	if scene_path == "":
		push_error("FlowController: load_scene: Scene path is empty for scene type: " + str(scene_type))
		return

	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(viewport_container, 'modulate:a', 0, FADE_DURATION)
	get_tree().paused = true
	await tween.finished

	if current_scene == null:
		get_tree().get_current_scene().call_deferred("queue_free")
	else:
		await(current_scene.call_deferred("queue_free"))
	var level: Node = load(scene_path).instantiate()
	await viewport.call_deferred('add_child', level)

	get_tree().paused = false
	tween = get_tree().create_tween()
	tween.tween_property(viewport_container, 'modulate:a', 1, FADE_DURATION)


func handle_input_pause() -> void:
	toggle_pause_game()
	print_debug('FlowController: handle_pause_input')



func pause_game(pause: bool):
	# pause_menu.visible = pause
	if pause:
		get_tree().paused = true
	else:
		get_tree().paused = false


func toggle_pause_game() -> void:
	pause_game(not get_tree().paused)
