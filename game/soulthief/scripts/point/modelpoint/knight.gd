extends Node3D

var hitbox : Hitbox
var hurtbox : Hurtbox

func _ready() -> void:
	var hit = Hitbox.new()
	self.add_child(hit)
	hit.id = str(self.get_instance_id())
	hit.global_transform.origin = self.global_transform.origin
	hit.global_rotation = self.global_rotation
	hit.position += Vector3(0.5, 1.6, 1.0)
	hit.rotation_degrees = Vector3(0.0, -14.0, -93.0)
	
	var hit_b = CollisionShape3D.new()
	hit.add_child(hit_b)
	var sword_bean = CapsuleShape3D.new()
	sword_bean.height = 1.0
	sword_bean.radius = 0.2
	hit_b.shape = sword_bean
	
	#var hit_m = MeshInstance3D.new()
	#hit.add_child(hit_m)
	#var s_m = CapsuleMesh.new()
	#s_m.height = sword_bean.height
	#s_m.radius = sword_bean.radius
	#hit_m.mesh = s_m
	hitbox = hit
	
	var hurt = Hurtbox.new()
	self.add_child(hurt)
	hurt.id = str(self.get_instance_id())
	hurt.global_transform.origin = self.global_transform.origin
	hurt.rotation_degrees = self.rotation_degrees
	hurt.position += Vector3.UP
	
	var hurt_b = CollisionShape3D.new()
	hurt.add_child(hurt_b)
	var knight_bean = CapsuleShape3D.new()
	knight_bean.height = 2.0
	knight_bean.radius = 0.5
	hurt_b.shape = knight_bean
	
	#var hurt_m = MeshInstance3D.new()
	#hurt.add_child(hurt_m)
	#var k_m = CapsuleMesh.new()
	#k_m.height = knight_bean.height
	#k_m.radius = knight_bean.radius
	#hurt_m.mesh = k_m
	hurtbox = hurt
	
	%Combat.activate(str(self.get_instance_id()), Combat.fighter_type.GUARD)
