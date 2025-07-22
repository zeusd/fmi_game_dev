@tool
extends SpotLight3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	self.spot_angle = props["angle"] as float
	self.spot_range = (props["range"] as float) * GameManager.INVERSE_SCALE
	self.spot_attenuation = props["attenuation"] as float
