@tool
class_name PathCorner
extends Marker3D

var activator
@export var globalname: String = ""
@export var targetname: String = ""
@export var target: String = ""
@export var targetfunc: String = ""

signal is_there

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	GAME.set_targetname(self, targetname)
	emit_signal("is_done")
	
	var area = CollisionShape3D.new()
	self.add_child(area)
	var shape = BoxShape3D.new()
	shape.size = Vector3.ONE
	area.shape = shape

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetfunc = props["targetfunc"] as String
	targetname = props["targetname"] as String
	globalname = props["globalname"] as String

func toggle_collision(toggle: bool) -> void:
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", !toggle)

func use() -> void:
	await activator.is_there
	toggle_collision(false)
	activator.target = target
	GAME.use_targets(self, target, activator)
