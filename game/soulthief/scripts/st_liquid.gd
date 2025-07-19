@tool
extends Area3D

const HM := SHADER_DIR + "CameraWaterOverlay.gdshader"

const MESH_INST_SUFF := "mesh_instance"
const SHADER_DIR := "res://shaders/"
const TXR_SPC_DIR := "res://assets/textures/special/"

const TXR_SUFF := ".tres"
const SHADER_SUFF := ".gdshader"
const SHD_MAT_SUFF := "_shader_material.tres"

const ST_LIQUID := "st_liquid"
const ST_WATER0 := "st_water0"
const ST_SLIME1 := "st_slime1"
const ST_LAVA1 := "st_lava1"

@onready var water0_shader : Shader = preload(SHADER_DIR + ST_WATER0 + SHADER_SUFF)
@onready var slime1_shader : Shader = preload(SHADER_DIR + ST_SLIME1 + SHADER_SUFF)
@onready var lava1_shader : Shader = preload(SHADER_DIR + ST_LAVA1 + SHADER_SUFF)

@onready var water0_shd_mat : ShaderMaterial = preload(SHADER_DIR + ST_WATER0 + SHD_MAT_SUFF)
@onready var slime1_shd_mat : ShaderMaterial = preload(SHADER_DIR + ST_SLIME1 + SHD_MAT_SUFF)
@onready var lava1_shd_mat : ShaderMaterial = preload(SHADER_DIR + ST_LAVA1 + SHD_MAT_SUFF)

var col_rect : ColorRect
@onready var hmh : Shader = preload(HM)

#func _physics_process(delta: float) -> void:
	#var player : Node3D = get_tree().get_nodes_in_group("player")[0]
	#var head : Area3D = player.find_child("HeadArea")

func _ready() -> void:
	col_rect = ColorRect.new()
	col_rect.visible = false
	col_rect.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	col_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col_rect.z_index = -10
	col_rect.z_as_relative = false
	col_rect.material = ShaderMaterial.new()
	(col_rect.material as ShaderMaterial).shader = hmh
	self.add_child(col_rect)
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)

func _on_body_entered(node: Node3D) -> void:
	pass

func _on_body_exited(node: Node3D) -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	col_rect.visible = true

func _on_area_exited(area: Area3D) -> void:
	col_rect.visible = false

func _func_godot_apply_properties(properties: Dictionary) -> void:
	var shader_dict : Dictionary = {
		ST_WATER0 : water0_shader,
		ST_SLIME1 : slime1_shader,
		ST_LAVA1 : lava1_shader
	}
	
	var shd_mat_dict : Dictionary = {
		ST_WATER0 : water0_shd_mat,
		ST_SLIME1 : slime1_shd_mat,
		ST_LAVA1 : lava1_shd_mat
	}
	
	var mesh_inst_name := self.name.trim_suffix(ST_LIQUID) + MESH_INST_SUFF
	var mesh_inst = self.find_child(mesh_inst_name) as MeshInstance3D
	
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
	
