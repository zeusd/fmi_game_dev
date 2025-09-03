class_name Bloodstain
extends Decal

@onready var blood_decal: Texture2D = preload("res://juice/blood_decal.png")

func _ready() -> void:
	self.size = Vector3(5.0, 5.0, 5.0)
	self.upper_fade = 0.0
	self.lower_fade = 0.0
	self.texture_albedo = blood_decal
	self.rotate_y(deg_to_rad(-90.0))
