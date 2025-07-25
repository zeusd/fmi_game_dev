class_name Blood
extends GPUParticles3D

func _ready() -> void:
	self.emitting = false
	self.amount = 21
	self.lifetime = 0.5
	self.one_shot = true
	self.explosiveness = 1.0
	self.fixed_fps = 60
	self.visibility_aabb = (AABB(Vector3(-1.5, -1.5, -1.5), Vector3(3.0, 3.0, 3.0)))
	
	var ppm = ParticleProcessMaterial.new()
	ppm.particle_flag_align_y = true
	ppm.spread = 180.0
	ppm.initial_velocity_min = 12.0
	ppm.initial_velocity_max = 21.0
	ppm.scale_min = 0.5
	ppm.scale_max = 3.0
	
	var curve_tex = CurveTexture.new()
	curve_tex.curve = Curve.new()
	curve_tex.curve.clear_points()
	curve_tex.curve.add_point(Vector2(0.0, 1.0))
	curve_tex.curve.add_point(Vector2(0.25, 1.0))
	curve_tex.curve.add_point(Vector2(1.0, 0.0))
	
	var cyl_mesh = CylinderMesh.new()
	cyl_mesh.top_radius = 0.1
	cyl_mesh.bottom_radius = 0.0
	cyl_mesh.radial_segments = 4
	
	var st_mat = StandardMaterial3D.new()
	st_mat.albedo_color = Color(0.5, 0.0, 0.0, 1.0)
	
	cyl_mesh.material = st_mat
	ppm.scale_curve = curve_tex
	self.draw_pass_1 = cyl_mesh
	self.process_material = ppm
	
