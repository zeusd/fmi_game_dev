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
var speed:= 3.0
var angry:= false
var alert:= false

signal is_there

var anim_p: AnimationPlayer
const A_IDLE:= "idle"
const A_IDLE_WALK:= "idle_walk"
const A_ALERT_WALK:= "alert_walk"
const A_RUN:= "run"
const A_READY:= "ready"
const A_SLASH:= "slash"
const A_HIT:= "hit"
const A_DEATH:= "death"
const A_BONK:= "bonk"

var idle_timer:= Timer.new()
var atk_timer:= Timer.new()
var pre_atk_timer:= Timer.new()

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetname = props["targetname"] as String
	globalname = props["globalname"] as String

func _ready() -> void:
	#(self.find_child("knight") as Node3D).scale = Vector3.ONE * 1.1
	#self.global_position.y += 0.2
	
	anim_p = self.find_child("knight").find_child("AnimationPlayer")
	
	self.add_child(idle_timer)
	self.add_child(atk_timer)
	self.add_child(pre_atk_timer)
	idle_timer.one_shot = true
	atk_timer.one_shot = true
	pre_atk_timer.one_shot = true
	
	if Engine.is_editor_hint():
		return
	GAME.use_targets(self, target)
	
	var hit = Hitbox.new()
	self.add_child(hit)
	hit.id = str(self.get_instance_id())
	hit.global_transform.origin = self.global_transform.origin
	hit.global_rotation = self.global_rotation
	hit.position += Vector3(1.0, 1.5, 0.0)
	
	var hit_b = CollisionShape3D.new()
	hit.add_child(hit_b)
	var sword_bean = CapsuleShape3D.new()
	sword_bean.height = 1.0
	sword_bean.radius = 1.0
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
	hurt.exclude["ball"] = hitbox
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
	sight.global_rotation_degrees += Vector3(-0.0, -90.0, 0.0)
	sight.position += Vector3.UP * 1.75
	
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
	
	if anim_p.current_animation == A_SLASH:
		hitbox.monitorable = pre_atk_timer.is_stopped()
	else:
		hitbox.monitorable = false
	
	var state: Intelligence.enemy_state = %Intelligence.state_is(str(self.get_instance_id()))
	
	if state == Intelligence.enemy_state.IDLE or state == Intelligence.enemy_state.ALERT:
		if target:
			var tar_gr = get_tree().get_first_node_in_group(target) as PathCorner
			move_to(tar_gr.global_position)
			smooth_look_at(tar_gr.global_position, delta)
			
			var anim = A_ALERT_WALK if alert else A_IDLE_WALK
			play_anim_loop(anim)
			
			if ((tar_gr.global_position - self.global_position) * Vector3(1.0, 0.0, 1.0)).length() < 0.1:
				self.emit_signal("is_there")
		else:
			play_anim_loop(A_IDLE)
	
	if state == Intelligence.enemy_state.FIGHT:
		if nav_target:
			nav_agent.target_position = nav_target.global_position
		var next = nav_agent.get_next_path_position()
		next.y -= 1.0
		last_known_pos = next
		if angry:
			smooth_look_at(last_known_pos, 5 * delta)
			if not sight.in_sight(nav_target):
				%Intelligence.unspotted(str(self.get_instance_id()), nav_target)
				nav_agent.target_position = last_known_pos
		
		if (last_known_pos - self.global_position).length() < 2.0:
			if idle_timer.is_stopped() and atk_timer.is_stopped():
				var rand = RandomNumberGenerator.new()
				rand.randomize()
				var atk_chance = 1.0 if angry else rand.randf_range(0.0, 1.0)
				if atk_chance < 0.3:
					idle_timer.start(1.5)
					play_anim_loop(A_READY)
				elif sight.in_sight(nav_target):
					atk_timer.start(1.5)
					play_anim_loop(A_SLASH)
		else:
			play_anim_loop(A_RUN)
			move_to(next, speed)
			smooth_look_at(next, 5 * delta)
	elif state == Intelligence.enemy_state.SEARCH:
		if not look_timer.is_stopped():
			play_anim_loop(A_ALERT_WALK)
			var angle 
			if (last_known_pos - self.global_position).length() < 0.1:
				angle = 90.0
				last_known_pos = self.global_position
				self.velocity = Vector3.ZERO
				angry = false
			else:
				angle = 15.0
				move_to(last_known_pos)
			if angry:
				smooth_look_at(last_known_pos, 5 * delta)
			smooth_rotate(angle if sin(Time.get_datetime_dict_from_system()["second"] * 0.5 - 0.5) < 0.0 else -angle, delta)
		else:
			%Intelligence.change_state(str(self.get_instance_id()), Intelligence.enemy_state.ALERT)
	
	move_and_slide()

func hit_by(who: Node3D) -> void:
	%Intelligence.change_state(str(self.get_instance_id()), Intelligence.enemy_state.FIGHT)
	nav_target = who
	angry = true

func move_to(pos: Vector3, spd: float = 1.0) -> void:
	var dir = (pos - self.global_position).normalized()
	self.velocity = dir * spd * Vector3(1.0, 0.0, 1.0)

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

func play_anim_loop(anim: String) -> void:
	if anim_p.current_animation != anim:
		anim_p.play(anim)
		if anim == A_SLASH:
			pre_atk_timer.start(0.6)

func change_state_anim(state: Intelligence.enemy_state) -> void:
	pass
