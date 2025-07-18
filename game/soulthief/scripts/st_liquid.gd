@tool
extends Area3D

const MESH_INST_SUFF := "mesh_instance"
const SHADER_DIR := "res://shaders/"
const TXR_SPC_DIR := "res://assets/textures/special/"

const TXR_SUFF := ".tres"
const SHADER_SUFF := ".gdshader"
const SHD_MAT_SUFF := "_shader_material.tres"

const ST_LIQUID := "st_liquid"
const ST_WATER0 := "st_water0"
const ST_SLIME1 := "st_slime1"

@onready var water0_shader : Shader = preload(SHADER_DIR + ST_WATER0 + SHADER_SUFF)
@onready var slime1_shader : Shader = preload(SHADER_DIR + ST_SLIME1 + SHADER_SUFF)

@onready var water0_shd_mat : ShaderMaterial = preload(SHADER_DIR + ST_WATER0 + SHD_MAT_SUFF)
@onready var slime1_shd_mat : ShaderMaterial = preload(SHADER_DIR + ST_SLIME1 + SHD_MAT_SUFF)

func _func_godot_apply_properties(properties: Dictionary) -> void:
	var shader_dict : Dictionary = {
		ST_WATER0 : water0_shader,
		ST_SLIME1 : slime1_shader
	}
	
	var shd_mat_dict : Dictionary = {
		ST_WATER0 : water0_shd_mat,
		ST_SLIME1 : slime1_shd_mat
	}
	
	var mesh_inst_name := self.name.trim_suffix(ST_LIQUID) + MESH_INST_SUFF
	var mesh_inst : MeshInstance3D = self.find_child(mesh_inst_name) as MeshInstance3D
	
	# # #
	# APPLY READY-MADE SHADER
	# # #
	var res_name = null
	var txr_name = null
	
	for key in shader_dict.keys():
		txr_name = mesh_inst.mesh.surface_get_material(0).resource_path
		txr_name = txr_name.trim_suffix(TXR_SUFF)
		txr_name = txr_name.trim_prefix(TXR_SPC_DIR)
		
		if key == txr_name:
			res_name = key
			break
	
	if res_name != null:
		var shader = shader_dict.get(res_name)
		var shd_mat = shd_mat_dict.get(res_name)

		shd_mat.shader = shader
		mesh_inst.mesh.surface_set_material(0, shd_mat)
	# # #
	else:
	# # #
	# GENERATE MATERIAL FOR SHADER CREATION
	# # #
		var material : StandardMaterial3D = mesh_inst.mesh.surface_get_material(0)
		
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		
		material.uv1_scale = Vector3(0.3, 0.3, 0.3)
		material.uv1_triplanar = true
	# # #
