@tool
class_name Loot
extends StaticBody3D

@export var target: String = ""
@export var targetname: String = ""
@export var globalname: String = ""

@export var value:= 0.0
@export var mesh_path: String = ""
@export var lt_type: String = ""

@export var trs_name:= ""
var trs: GAME.treasures

var shader_mat: ShaderMaterial

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetname = props["targetname"] as String
	globalname = props["globalname"] as String
	value = props["value"] as float
	mesh_path = props["mesh_path"] as String
	lt_type = props["lt_type"] as String
	trs_name = props["trs_name"] as String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var mesh_arr = self.find_child(mesh_path, true)
	mesh_arr.mesh = mesh_arr.mesh.duplicate()
	var mat = mesh_arr.mesh.surface_get_material(0).duplicate()
	mesh_arr.mesh.surface_set_material(0, mat)
	mat.next_pass = mat.next_pass.duplicate()
	shader_mat = mat.next_pass
	
	var lt_t: Treasure.loot_type
	
	if lt_type == "special":
		lt_t = Treasure.loot_type.SPC
		trs = GAME.resolve_treasure(trs_name)
	else:
		lt_t = Treasure.loot_type.REG
	%Treasure.activate(str(self.get_instance_id()), lt_t)

var lit_up:= false:
	set(v):
		lit_up = v
		if lit_up:
			shader_mat.set_shader_parameter("strength", 0.42)
		else:
			shader_mat.set_shader_parameter("strength", 0.0)
	

func take() -> void:
	%Treasure.take(str(self.get_instance_id()))
	self.queue_free()
