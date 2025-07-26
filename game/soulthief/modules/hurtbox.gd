class_name Hurtbox
extends Area3D

var id: String
var exclude: Dictionary = {}

func _ready() -> void:
	self.area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area3D) -> void:
	for hb in exclude:
		if hitbox == exclude[hb]:
			return
	
	var combat
	for node in get_tree().get_nodes_in_group("COMPONENT"):
		if node is Combat:
			combat = node
			break
	
	if hitbox != null and hitbox is Hitbox:
		combat.hit(hitbox.id, self.id)
