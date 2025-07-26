extends Camera3D

@export var main_camera: Node3D

func _process(delta: float) -> void:
	self.global_transform = main_camera.global_transform
