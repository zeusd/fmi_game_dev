class_name Sight
extends Node3D

var id : String

var intelligence : Intelligence

func _ready() -> void:
	var vision = VisionCone3D.new()
	self.add_child(vision)
	vision.set_collision_mask_value(1, false)
	vision.set_collision_mask_value(5, true)
	vision.debug_draw = true
	
	for node in get_tree().get_nodes_in_group("COMPONENT"):
		if node is Intelligence:
			intelligence = node
			break
	
	vision.body_sighted.connect(_on_spotted)
	vision.body_exited.connect(_on_unspotted)

func _on_spotted(body: Node3D) -> void:
	intelligence.spotted(id, body)

func _on_unspotted(body: Node3D) -> void:
	intelligence.unspotted(id, body)
