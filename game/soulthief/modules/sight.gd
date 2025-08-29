class_name Sight
extends Node3D

var id: String

var intelligence: Intelligence

var vision_c: VisionCone3D
var vision_l: VisionCone3D
var vision_r: VisionCone3D

func _ready() -> void:
	vision_c = VisionCone3D.new()
	self.add_child(vision_c)
	vision_c.angle = 60
	#vision_c.range = 10.0
	#vision_c.rotate_x(deg_to_rad(-15.0))
	vision_c.set_collision_mask_value(1, false)
	vision_c.set_collision_mask_value(5, true)
	#vision_c.debug_draw = true
	
	vision_l = VisionCone3D.new()
	self.add_child(vision_l)
	vision_l.angle = 30
	#vision_l.range = 10.0
	#vision_l.rotate_x(deg_to_rad(-7.50))
	vision_l.set_collision_mask_value(1, false)
	vision_l.set_collision_mask_value(5, true)
	vision_l.rotate_y(deg_to_rad(37.7))
	#vision_l.debug_draw = true
	
	vision_r = VisionCone3D.new()
	self.add_child(vision_r)
	vision_r.angle = 30
	#vision_r.range = 10.0
	vision_r.set_collision_mask_value(1, false)
	vision_r.set_collision_mask_value(5, true)
	vision_r.rotate_y(deg_to_rad(-37.7))
	#vision_r.debug_draw = true
	
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
	if vision_c.overlaps_body(body) or vision_l.overlaps_body(body) or vision_r.overlaps_body(body):
		return
	intelligence.unspotted(id, body)

func in_sight(body: Node3D) -> bool:
	if body == null:
		return false
	return vision_c.overlaps_body(body) or vision_l.overlaps_body(body) or vision_r.overlaps_body(body)
