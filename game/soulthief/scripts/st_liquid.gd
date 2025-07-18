@tool
extends Area3D

const ST_LIQUID := "st_liquid"
const MESH_INST_SUFF := "mesh_instance"
const SHADER_DIR := "res://shaders/"

@onready var shader : Shader = preload(SHADER_DIR + ST_LIQUID + ".gdshader")
@onready var shader_material : ShaderMaterial = preload(SHADER_DIR + ST_LIQUID + "_shader_material.tres")

func _func_godot_apply_properties(properties: Dictionary) -> void:
	var mesh_inst_name := self.name.trim_suffix(ST_LIQUID) + MESH_INST_SUFF
	var mesh_inst : MeshInstance3D = self.find_child(mesh_inst_name) as MeshInstance3D
	
	# # #
	# APPLY PRE-MADE SHADER
	# # #
	shader_material.shader = shader
	mesh_inst.mesh.surface_set_material(0, shader_material)
	# # #
	
	# # #
	# GENERATE MATERIAL FOR SHADER CREATION
	# # #
	#var material : StandardMaterial3D = mesh_inst.mesh.surface_get_material(0)
	#
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#material.cull_mode = BaseMaterial3D.CULL_DISABLED
	#material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	#
	#material.uv1_scale = Vector3(0.6, 0.6, 0.6)
	#material.uv1_triplanar = true
	# # #
