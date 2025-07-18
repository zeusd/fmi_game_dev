@tool
extends Area3D

const ST_WATER := "st_water"
const MESH_SUFF := "mesh_instance"
const SHADER_PATH := "res://shaders/"

@onready var shader : Shader = preload(SHADER_PATH + ST_WATER + ".gdshader")
@onready var shader_mat : ShaderMaterial = preload(SHADER_PATH + ST_WATER + "_shader_mat.tres")

#@onready var shader : Shader = preload(SHADER_PATH + "gg.gdshader")
#@onready var shader_mat : ShaderMaterial = preload(SHADER_PATH + "gg.tres")


func _func_godot_apply_properties(properties: Dictionary) -> void:
	var mesh_name = self.name.trim_suffix(ST_WATER) + MESH_SUFF
	var mesh_instance : MeshInstance3D = self.find_child(mesh_name)
	var material : StandardMaterial3D = StandardMaterial3D.new() #mesh.mesh.surface_get_material(0)
	mesh_instance.mesh.surface_set_material(0, material)
	
	
	# # #
	# USE SHADER
	# # #
	shader_mat.shader = shader
	mesh_instance.mesh.surface_set_material(0, shader_mat)
	# # #
	
	# # #
	# REPRODUCE MATERIAL FOR SHADER CREATION
	# # #
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#material.cull_mode = BaseMaterial3D.CULL_DISABLED
	#material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	#
	#material.albedo_color = Color(0.0, 0.42, 1.0, 0.3)
	#material.albedo_texture = null
	#
	#var noise_texture = NoiseTexture2D.new()
	#noise_texture.seamless = true
	#noise_texture.as_normal_map = true
	#noise_texture.noise = FastNoiseLite.new()
	#material.normal_enabled = true
	#material.normal_texture = noise_texture
	#
	#material.roughness = 0
	#
	#material.refraction_enabled = true
	#material.refraction_texture = material.normal_texture
	#
	#material.uv1_triplanar = true
	#material.uv1_world_triplanar = true
	# # #
	
