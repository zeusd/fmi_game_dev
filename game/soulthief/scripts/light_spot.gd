@tool
extends SpotLight3D

func _func_godot_apply_properties(properties: Dictionary) -> void:
	self.light_energy = properties["light"] as float
	self.light_color = properties["color"] as Color
	
	self.spot_range = properties["range"] as float
	self.spot_angle = properties["spot_angle"] as float
	self.spot_attenuation = properties["attenuation"] as float
	self.rotation_degrees = properties["rotation_deg"] as Vector3
