class_name WeaponResource
extends Resource

var weapon_manager: WeaponManager
@export var view_model: PackedScene

@export var wep_name: String
@export var pos: Vector3
@export var rot: Vector3

# # # Animations
@export var hold_anim: String
@export var strike_anim: String
@export var revert_anim: String

# # # Sounds
#@export var hold_sound: AudioStream
#@export var strike_sound: AudioStream
#@export var revert_sound: AudioStream

var is_eqipped := false:
	set(v):
		is_eqipped = v
		if is_eqipped:
			on_equip()
		else:
			on_unequip()

func on_strike() -> void:
	if strike_anim and weapon_manager.get_anim(self) == strike_anim:
		return
	_strike()

func on_hold() -> void:
	if hold_anim and weapon_manager.get_anim(self) == hold_anim:
		return
	_hold()

func _strike() -> void:
	weapon_manager.play_anim(self, strike_anim)
	#weapon_manager.play_sound(strike_sound)

func _hold() -> void:
	weapon_manager.play_anim(self, hold_anim)

func on_equip() -> void:
	pass

func on_unequip() -> void:
	pass
