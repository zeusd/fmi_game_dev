class_name Sight
extends Node3D

var id: String

var intelligence: Intelligence

func _ready() -> void:
	var vision_c = VisionCone3D.new()
	self.add_child(vision_c)
	vision_c.angle = 45
	vision_c.set_collision_mask_value(1, false)
	vision_c.set_collision_mask_value(5, true)
	vision_c.debug_draw = true
	
	var vision_l = VisionCone3D.new()
	self.add_child(vision_l)
	vision_l.angle = 30
	vision_l.set_collision_mask_value(1, false)
	vision_l.set_collision_mask_value(5, true)
	vision_l.rotate_y(deg_to_rad(37.7))
	vision_l.debug_draw = true
	
	var vision_r = VisionCone3D.new()
	self.add_child(vision_r)
	vision_r.angle = 30
	vision_r.set_collision_mask_value(1, false)
	vision_r.set_collision_mask_value(5, true)
	vision_r.rotate_y(deg_to_rad(-37.7))
	vision_r.debug_draw = true
	
	for node in get_tree().get_nodes_in_group("COMPONENT"):
		if node is Intelligence:
			intelligence = node
			break
	
	vision_c.body_sighted.connect(_on_spotted)
	vision_c.body_hidden.connect(_on_unspotted)
	vision_l.body_sighted.connect(_on_spotted)
	vision_l.body_hidden.connect(_on_unspotted)
	vision_r.body_sighted.connect(_on_spotted)
	vision_r.body_hidden.connect(_on_unspotted)

func _on_spotted(body: Node3D) -> void:
	intelligence.spotted(id, body)

func _on_unspotted(body: Node3D) -> void:
	intelligence.unspotted(id, body)
