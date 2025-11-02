extends Control


class_name IngameUI


@onready var bullet_container: HBoxContainer = %AmmoContainer
var bullet_widget_scene: PackedScene = preload("res://scenes/UI/bullet_widget.tscn")


var _magazine_size: int = 0

func _ready() -> void:
	PlayerStateAutoload.set_ingame_ui(self)


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
