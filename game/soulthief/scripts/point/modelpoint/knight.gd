@tool
class_name Knight
extends CharacterBody3D

@export var target: String = ""
@export var targetname: String = ""
@export var globalname: String = ""

var hitbox: Hitbox
var hurtbox: Hurtbox

var sight: Sight
var nav_target: Node3D
var look_timer: Timer
var last_known_pos: Vector3

var nav_agent: NavigationAgent3D
var speed := 4.0

signal is_there

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetname = props["targetname"] as String
	globalname = props["globalname"] as String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	#GAME.set_targetname(self, targetname)
	GAME.use_targets(self, target)
	
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
	
	sight = Sight.new()
	self.add_child(sight)
	sight.id = str(self.get_instance_id())
	sight.global_rotation = self.global_rotation
	sight.global_rotation_degrees += Vector3(0.0, -90.0, 0.0)
	sight.position += Vector3.UP * 1.85
	
	self.nav_agent = NavigationAgent3D.new()
	self.add_child(nav_agent)
	nav_agent.target_position = self.global_position
	
	look_timer = Timer.new()
	self.add_child(look_timer)
	look_timer.one_shot = true
	
	%Intelligence.activate(str(self.get_instance_id()), Intelligence.enemy_type.KNIGHT)
	%Combat.activate(str(self.get_instance_id()), Combat.fighter_type.KNIGHT)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var state: Intelligence.enemy_state = %Intelligence.state_is(str(self.get_instance_id()))
	
	if state == Intelligence.enemy_state.IDLE or state == Intelligence.enemy_state.ALERT:
		var tar_gr = get_tree().get_first_node_in_group(target) as PathCorner
		move_to(tar_gr.global_position)
		smooth_look_at(tar_gr.global_position, delta)
		
		if (tar_gr.global_position - self.global_position).length() < 0.1:
			self.emit_signal("is_there")
	
	if state == Intelligence.enemy_state.FIGHT:
		nav_agent.target_position = nav_target.global_position
		var next = nav_agent.get_next_path_position()
		next.y -= 1.0
		last_known_pos = next
		move_to(next)
		smooth_look_at(next, delta)
	elif state == Intelligence.enemy_state.SEARCH:
		if not look_timer.is_stopped():
			var angle 
			if (last_known_pos - self.global_position).length() < 0.5:
				angle = 90.0
				last_known_pos = self.global_position
				self.velocity = Vector3.ZERO
			else:
				angle = 15.0
				move_to(last_known_pos)
			smooth_rotate(angle if sin(Time.get_datetime_dict_from_system()["second"] * 0.5 - 0.5) < 0.0 else -angle, delta)
		else:
			%Intelligence.change_state(str(self.get_instance_id()), %Intelligence.enemy_state.ALERT)
	
	move_and_slide()

func move_to(pos: Vector3) -> void:
	var dir = (pos - self.global_position).normalized()
	self.velocity = dir# * speed

func smooth_look_at(to: Vector3, delta: float) -> void:
	if (to - self.global_position).length() < 0.1:
		return
	var old_tr = self.transform
	self.look_at(to, Vector3.UP)
	self.rotation = self.rotation * Vector3(0.0, 1.0, 0.0)
	self.rotation_degrees += Vector3(0.0, 90.0, 0.0)
	var new_tr = self.transform
	self.transform = old_tr
	self.transform = self.transform.interpolate_with(new_tr, speed * delta)

func smooth_rotate(angle: float, delta: float) -> void:
	var old_tr = self.transform
	self.rotation_degrees += Vector3(0.0, angle, 0.0)
	var new_tr = self.transform
	self.transform = old_tr
	self.transform = self.transform.interpolate_with(new_tr, delta)
