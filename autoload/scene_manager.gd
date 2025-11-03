extends Node
class_name SceneManager

const FADE_DURATION: float = 0.5
var current_scene: SceneBase
var viewport_container: SubViewportContainer
var viewport: SubViewport
var pause_menu: SettingMenu
var last_increment_index: int = 0

var ingame_ui_scene: PackedScene = preload("res://scenes/UI/ingame_ui.tscn")
var ingame_ui: IngameUI

var _paused = false

signal scene_changed(new_scene: SceneBase)

var shader_material :ShaderMaterial

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

	shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/crt.gdshader")
	viewport_container.material = shader_material
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	shader_material.set_shader_parameter("tex", viewport.get_texture())
	shader_material.set_shader_parameter("chromatic_aberration_intensity", 0.005)
	shader_material.set_shader_parameter("vignette_amount", 0.914)
	shader_material.set_shader_parameter("vignette_radius", 0.807)


	get_tree().create_timer(0.3).timeout.connect(_on_ready_timeout)
	viewport.connect("size_changed", _on_viewport_size_changed)



	ingame_ui = ingame_ui_scene.instantiate()
	ingame_ui.z_index = 100
	ingame_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	await viewport.call_deferred("add_child", ingame_ui)

	var pause_menu_scene: PackedScene = preload("res://scenes/UI/SettingMenu.tscn")
	pause_menu = pause_menu_scene.instantiate()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.set_visibility(false)

	await viewport.call_deferred("add_child", pause_menu)


func _on_viewport_size_changed() -> void:
	shader_material.set_shader_parameter("tex", viewport.get_texture())

func _on_ready_timeout():
	viewport_container.set_visible(true)
	get_tree().get_root().move_child(viewport_container, 0)
	scene_changed.emit(current_scene)
	if current_scene is SceneBase:
		ingame_ui.visible = current_scene.show_ingame_ui


func set_current_scene(in_scene: SceneBase) -> void:
	current_scene = in_scene
	current_scene.call_deferred("reparent", viewport, true)
	scene_changed.emit(current_scene)
	if current_scene is SceneBase:
		ingame_ui.visible = current_scene.show_ingame_ui


func get_current_scene() -> SceneBase:
	return current_scene


func load_scene(scene_type: SceneMapping.SceneType) -> void:
	var scene_path: String = SceneMapping.get_scene_path(scene_type)
	if scene_path == "":
		push_error("FlowController: load_scene: Scene path is empty for scene type: " + str(scene_type))
		return

	if scene_type == SceneMapping.SceneType.GAME:
		PlayerStateAutoload.reset()

	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(viewport_container, 'modulate:a', 0, FADE_DURATION)
	get_tree().paused = true
	_paused = true
	await tween.finished

	if current_scene == null:
		get_tree().get_current_scene().call_deferred("queue_free")
	else:
		await(current_scene.call_deferred("queue_free"))
	var level: Node = load(scene_path).instantiate()
	await viewport.call_deferred('add_child', level)

	get_tree().paused = false
	_paused = false
	tween = get_tree().create_tween()
	tween.tween_property(viewport_container, 'modulate:a', 1, FADE_DURATION)


func handle_input_pause() -> void:
	toggle_pause_game()
	print_debug('FlowController: handle_pause_input')


func pause_game(pause: bool):
	_paused = pause
	pause_menu.set_visibility(_paused)
	if current_scene is SceneBase:
		if pause:
			current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			current_scene.process_mode = Node.PROCESS_MODE_INHERIT
		current_scene.visible = not pause
	else:
		get_tree().paused = _paused



func toggle_pause_game() -> void:
	pause_game(not _paused)
