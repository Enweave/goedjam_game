extends TextureRect

class_name BulletWidget


@export var bullet_icon: Texture2D
@export var bullet_spent_icon: Texture2D

func toggle_bullet(is_spent: bool) -> void:
	if is_spent:
		self.texture = bullet_spent_icon
	else:
		self.texture = bullet_icon