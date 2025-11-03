extends AIController


class_name MeleeAIController

@export var weapon: MeleeWeapon = null


func _ready() -> void:
	super._ready()
	if current_target_node:
		weapon.set_target_object(current_target_node)
		weapon.OnTargetInRangeChanged.connect(_on_weapon_target_in_range_changed)
		weapon.OnActivation.connect(_on_weapon_activation)
		weapon.OnCooldownPassed.connect(_on_weapon_target_in_range_changed)

		OnControlledCharacterDied.connect(_on_controlled_character_died)


func _on_controlled_character_died() -> void:
	weapon.OnTargetInRangeChanged.disconnect(_on_weapon_target_in_range_changed)
	weapon.OnActivation.disconnect(_on_weapon_activation)
	weapon.OnCooldownPassed.disconnect(_on_weapon_target_in_range_changed)

func _on_weapon_target_in_range_changed() -> void:
	if weapon.target_in_range:
		weapon.activate()
		if sprite_hanlde:
			sprite_hanlde.do_melee_attack_animation()
	else:
		weapon.deactivate()


func _on_weapon_activation() -> void:
	if current_target_node and weapon.target_in_range:
		WeaponBase.damage_character(current_target_node, weapon.damage)


