extends Control


class_name IngameUI


@onready var bullet_container: HBoxContainer = %AmmoContainer
@onready var health_widget: ProgressBar = %Health
@onready var game_over_widget: Control = %GameOverWidget
var bullet_widget_scene: PackedScene = preload("res://scenes/UI/bullet_widget.tscn")


@onready var wave_widget: Control = %WaveWidget
@onready var wave_label: Label = %WaveLabel
@onready var wave_anim_player: AnimationPlayer = %WaveAnimationPlayer
@onready var results_container: Control = %ResultsContainer


var result_label_scene : PackedScene = preload("res://scenes/UI/results_label.tscn")

var _magazine_size: int = 0


func update_wave_display(in_wave: int) -> void:
	wave_widget.visible = true
	wave_label.text = "Wave %d incoming!" % in_wave
	wave_anim_player.play("reveal")


func reset() -> void:
	_update_magazine_size(0)
	game_over_widget.visible = false


func add_endgame_stat(in_name: String, in_value: String) -> void:
	var name_label: Label = result_label_scene.instantiate()
	var value_label: Label = result_label_scene.instantiate()
	name_label.text = in_name
	value_label.text = in_value
	results_container.add_child(name_label)
	results_container.add_child(value_label)

func game_over() -> void:
	game_over_widget.visible = true
	for child in results_container.get_children():
		results_container.remove_child(child)
		child.queue_free()

	add_endgame_stat("Waves Survived", str(PlayerStateAutoload.current_wave - 1))
	add_endgame_stat("Enemies Killed", str(PlayerStateAutoload.enemies_killed))


func _ready() -> void:
	PlayerStateAutoload.set_ingame_ui(self)
	%MainMenuButton.pressed.connect(func() -> void:
		SceneManagerAutoload.load_scene(SceneMapping.SceneType.MAIN_MENU)
		game_over_widget.visible = false
	)

	wave_anim_player.animation_finished.connect(_on_wave_animation_finished)


func _on_wave_animation_finished(_anim_name: String) -> void:
	wave_widget.visible = false

func update_health_display(in_health_component: HealthComponent) -> void:
	health_widget.value = in_health_component.current_health / in_health_component.current_max_health * 100.0
	health_widget.custom_minimum_size.x = in_health_component.current_max_health * 10


func _update_magazine_size(in_size: int) -> void:
	if _magazine_size != in_size:
		_magazine_size = in_size
		for child in bullet_container.get_children():
			bullet_container.remove_child(child)
			child.queue_free()

		for i in range(_magazine_size):
			var bullet_widget: BulletWidget = bullet_widget_scene.instantiate()
			bullet_container.add_child(bullet_widget)


func update_weapon_display(in_weapon: PlayerWeapon) -> void:
	var bullet_count: int = in_weapon.current_ammo
	var max_bullet_count: int = in_weapon.magazine_size

	_update_magazine_size(max_bullet_count)

	for i in range(max_bullet_count):
		var bullet_widget: BulletWidget = bullet_container.get_child(i) as BulletWidget
		if i < bullet_count:
			bullet_widget.toggle_bullet(false)
		else:
			bullet_widget.toggle_bullet(true)
