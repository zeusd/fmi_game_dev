@tool
extends OmniLight3D

func _func_godot_apply_properties(properties: Dictionary) -> void:
	self.light_energy = properties["light"] as float
	self.light_color = properties["color"] as Color
	
	self.omni_range = properties["range"] as float
	self.omni_attenuation = properties["attenuation"] as float
