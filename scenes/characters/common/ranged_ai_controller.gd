extends AIController


class_name RangedAiController


@export var weapon: RangedWeapon = null


func _ready() -> void:
	super._ready()
	if current_target_node:
		weapon.set_target_object(current_target_node)
		weapon.instigator = self.get_parent()
		weapon.OnTargetInRangeChanged.connect(_on_weapon_target_in_range_changed)
		weapon.OnCooldownPassed.connect(_on_weapon_target_in_range_changed)

		OnControlledCharacterDied.connect(_on_controlled_character_died)


func _on_controlled_character_died() -> void:
	weapon.disable_feature()
	weapon.OnTargetInRangeChanged.disconnect(_on_weapon_target_in_range_changed)
	weapon.OnCooldownPassed.disconnect(_on_weapon_target_in_range_changed)


func _on_weapon_target_in_range_changed() -> void:
	if weapon.target_in_range:
		chase_enabled = false
		weapon.activate()
		if sprite_hanlde:
			sprite_hanlde.do_melee_attack_animation()
	else:
		chase_enabled = true
		weapon.deactivate()

