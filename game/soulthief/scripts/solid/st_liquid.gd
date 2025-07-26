@tool
extends Area3D

const MESH_INST_SUFF := "mesh_instance"
const SHADER_DIR := "res://shaders/"
const TXR_SPC_DIR := "res://assets/textures/special/"

const TXR_SUFF := ".tres"
const SHADER_SUFF := ".gdshader"
const SHD_MAT_SUFF := "_shader_material.tres"

const TINT := "tint"
const DENS := "dens"
const ST_RIPPLE := "st_ripple_overlay"

var env: WorldEnvironment = null
const COL_MULT := 0.6
const FOG_DIV := 300

const WATER_DENS := 0.2
const SLIME_DENS := 0.25
const LAVA_DENS := 0.3

const WATER_TINT := Vector4(0, 5, 10, 0)
const LAVA_TINT := Vector4(10, 2, 0, 0)
const SLIME_TINT := Vector4(0, 3, 0, 0)

@export var col_rect: ColorRect
@export var liquid_type: int
@export var gamma: float

const LIQ_TYPES := {
	0: {
		TINT: WATER_TINT,
		DENS: WATER_DENS
	},
	1: {
		TINT: SLIME_TINT,
		DENS: SLIME_DENS
	},
	2: {
		TINT: LAVA_TINT,
		DENS: LAVA_DENS
	}
}

const ST_LIQUID := "st_liquid"
const ST_WATER0 := "st_water0"
const ST_SLIME1 := "st_slime1"
const ST_LAVA1 := "st_lava1"

@onready var water0_shader: Shader = preload(SHADER_DIR + ST_WATER0 + SHADER_SUFF)
@onready var slime1_shader: Shader = preload(SHADER_DIR + ST_SLIME1 + SHADER_SUFF)
@onready var lava1_shader: Shader = preload(SHADER_DIR + ST_LAVA1 + SHADER_SUFF)

@onready var water0_shd_mat: ShaderMaterial = preload(SHADER_DIR + ST_WATER0 + SHD_MAT_SUFF)
@onready var slime1_shd_mat: ShaderMaterial = preload(SHADER_DIR + ST_SLIME1 + SHD_MAT_SUFF)
@onready var lava1_shd_mat: ShaderMaterial = preload(SHADER_DIR + ST_LAVA1 + SHD_MAT_SUFF)

@onready var ripple_shader: Shader = preload(SHADER_DIR + ST_RIPPLE + SHADER_SUFF)

#func _physics_process(delta: float) -> void:
	#var player: Node3D = get_tree().get_nodes_in_group("PLAYER")[0]
	#var head: Area3D = player.find_child("HeadArea")

func _ready() -> void:
	self.add_to_group("LIQUID")
	# # #
	# SCREEN RIPPLE EFFECT
	# # #
	col_rect = ColorRect.new()
	col_rect.visible = false
	col_rect.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	col_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col_rect.z_index = -10
	col_rect.z_as_relative = false
	col_rect.material = ShaderMaterial.new()
	(col_rect.material as ShaderMaterial).shader = ripple_shader
	(col_rect.material as ShaderMaterial).set_shader_parameter(TINT, (LIQ_TYPES[liquid_type][TINT]) * COL_MULT)
	self.add_child(col_rect)
	
	env = self.get_tree().get_nodes_in_group("ENV")[0] as WorldEnvironment
	
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)

func _on_body_entered(node: Node3D) -> void:
	pass

func _on_body_exited(node: Node3D) -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("CAM"):
		col_rect.visible = true
		env.environment.volumetric_fog_density = LIQ_TYPES[liquid_type][DENS]
		var col = LAVA_TINT / FOG_DIV
		env.environment.volumetric_fog_albedo = Color(col.x, col.y, col.z, col.w)

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("CAM"):
		col_rect.visible = false
		env.environment.volumetric_fog_density = 0.0
		env.environment.volumetric_fog_albedo = Color.WHITE

func _func_godot_apply_properties(properties: Dictionary) -> void:
	var shader_dict: Dictionary = {
		ST_WATER0: water0_shader,
		ST_SLIME1: slime1_shader,
		ST_LAVA1: lava1_shader
	}
	
	var shd_mat_dict: Dictionary = {
		ST_WATER0: water0_shd_mat,
		ST_SLIME1: slime1_shd_mat,
		ST_LAVA1: lava1_shd_mat
	}
	
	liquid_type = properties.get("liquid_type")
	gamma = properties.get("gamma")
	
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
		var shader: Shader = shader_dict.get(res_name)
		var shd_mat: ShaderMaterial = shd_mat_dict.get(res_name)
		
		shd_mat.shader = shader
		mesh_inst.mesh.surface_set_material(0, shd_mat)
		var albedo = shd_mat.get_shader_parameter("albedo") as Color
		albedo.a = gamma
		shd_mat.set_shader_parameter("albedo", albedo)
	# # #
	else:
	# # #
	# GENERATE MATERIAL FOR SHADER CREATION
	# # #
		var material: StandardMaterial3D = mesh_inst.mesh.surface_get_material(0)
		
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		
		material.uv1_scale = Vector3(0.3, 0.3, 0.3)
		material.uv1_triplanar = true
	# # #
