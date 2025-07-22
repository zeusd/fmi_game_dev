extends CharacterBody3D

@export var x_mouse_sensitivity : float = 0.006
@export var y_mouse_sensitivity : float = 0.006

@export var x_stick_sensitivity : float = 0.12
@export var y_stick_sensitivity : float = 0.12
@export var stick_look_smoothing : float = 0.3

@export var headbob_move := 0.06
@export var headbob_frequency := 2.4
var headbob_time := 0.0

var cur_stick_look := Vector2.ZERO

@export var jump_velocity := 5.3
@export var walk_speed := 5.3
@export var sprint_speed := 7.7
var sprinting := false

const WALLRUN_POWER = 3
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_bounce := Vector3.ZERO
var wall_normal := Vector3.ZERO

const MAX_JUMPS := 1
var jump_cnt := 0
var jump_timer : Timer = Timer.new()
var jump_timeout := jump_velocity / gravity

const MAX_STEP_HEIGHT := 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_on_floor := -INF

const CROUCH_DIST = 0.7
const CROUCH_SLOW = 0.5
const CROUCH_JUMP_ADD = CROUCH_DIST * 0.9
var crouching = false

@export var frict := 6.0
@export var accel := 100.0
@export var stop_speed := 100.0
@export var max_speed := 320.0
@export var air_move_cap := 0.85
@export var air_speed := 500.0

@export var swim_up_speed := 7.0
@export var water_speed_mult := 1.0
var swimming = false

const WEIGHT := 100
const FORCE := 1.0
const THROW_FORCE := 70

#signal interact_obj
var held_obj : RigidBody3D
var look_speed : float

var wish_dir := Vector3.ZERO
var cam_aligned_wish_dir := Vector3.ZERO

const NOCLIP_SPEED_ORIG := 3.0
var noclip_speed_mult := NOCLIP_SPEED_ORIG
var noclip := false

func get_speed() -> float:
	var speed = sprint_speed if sprinting else walk_speed
	return speed * CROUCH_SLOW if crouching else speed

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()
	
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _ready():
	for child in %PlayerModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)
	
	%sword_down.visible = false
	%sword_up.visible = true
	
	add_child(jump_timer)
	jump_timer.one_shot = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * x_mouse_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * y_mouse_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			
			look_speed = event.screen_relative.length()
		else:
			look_speed = 0.0
	if noclip:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				noclip_speed_mult = min(100.0, noclip_speed_mult * 1.1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				noclip_speed_mult = max(0.1, noclip_speed_mult * 0.9)

func _handle_stick_look_input(delta: float) -> void:
	var target_look = Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
	
	if target_look.length() < cur_stick_look.length():
		cur_stick_look = target_look
	else:
		cur_stick_look = cur_stick_look.lerp(target_look, (1 / stick_look_smoothing) * delta)
	
	rotate_y(-cur_stick_look.x * x_stick_sensitivity)
	%Camera3D.rotate_x(-cur_stick_look.y * y_stick_sensitivity)
	%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if held_obj == null:
			_hold_object()
		else:
			_drop_object()
	if held_obj != null and Input.is_action_just_pressed("attack"):
		_drop_object(THROW_FORCE)
	elif Input.is_action_just_pressed("attack"):
		if crouching:
			%AnimationPlayer.play("stealth_hit")
		else:
			%AnimationPlayer.play("hit")

var _saved_camera_global_pos = null
func _save_camera_pos() -> void:
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = %CameraSmooth.global_position

func _slide_camera_smooth(delta) -> void:
	if _saved_camera_global_pos == null:
		return
	
	%CameraSmooth.global_position.y = _saved_camera_global_pos.y
	%CameraSmooth.position.y = clampf($%CameraSmooth.position.y, -0.7, 0.7)
	var move_amount = max(self.velocity.length() * delta, (walk_speed / 2) * delta)
	%CameraSmooth.position.y = move_toward(%CameraSmooth.position.y, 0.0, move_amount)
	_saved_camera_global_pos = %CameraSmooth.global_position
	
	if is_zero_approx(%CameraSmooth.position.y):
		_saved_camera_global_pos = null

func _headbob_effect(delta: float) -> void:
	headbob_time += self.velocity.length() * delta
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * headbob_frequency * 0.5) * headbob_move,
		sin(headbob_time * headbob_frequency) * headbob_move,
		0
	)

func _process(delta: float) -> void:
	#if %Interaction.is_colliding():
		#var reach = %Interaction.get_collider()
		#interact_obj.emit(reach)
	#else:
		#interact_obj.emit(null)
	
	sprinting = Input.is_action_pressed("sprint") or Input.is_action_pressed("sprint_1") or Input.is_action_pressed("sprint_2")
	
	if is_on_floor() or _snapped_to_stairs_last_frame:
		_last_frame_on_floor = Engine.get_physics_frames()
	
	_handle_stick_look_input(delta)
	_crouch_uncrouch(delta)
	
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	wish_dir = self.global_transform.basis * Vector3(-input_dir.x , 0.0, -input_dir.y)
	cam_aligned_wish_dir = %Camera3D.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	if not _handle_noclip(delta):
		if not _handle_liquid_physics(delta):
			if is_on_floor() or _snapped_to_stairs_last_frame:
				jump_cnt = 0
				jump_timer.stop()
				_handle_ground_physics(delta)
			else:
				_handle_air_physics(delta)
	
		var jumping : bool = Input.is_action_just_pressed("jump") if jump_cnt == 0 else Input.is_action_pressed("jump")
		if jumping and  jump_cnt < MAX_JUMPS and jump_timer.is_stopped():
			self.velocity.y += jump_velocity * ((jump_cnt / (jump_velocity / MAX_JUMPS)) + 1)
			jump_timer.start(jump_timeout)
			jump_cnt += 1

		if not _snap_up_stairs_check(delta):
			_push_rigid_bodies()
			move_and_slide()
			_snap_down_stairs_check()
	
	if held_obj != null:
		var obj_pos = held_obj.global_transform.origin
		var target_pos = %Hand.global_transform.origin
		held_obj.global_position -= obj_pos - target_pos
	
	_slide_camera_smooth(delta)

func _physics_process(_delta: float) -> void:
	pass

func _handle_noclip(delta: float) -> bool:
	if Input.is_action_just_pressed("_noclip") and OS.has_feature("debug"):
		noclip = !noclip
		noclip_speed_mult = NOCLIP_SPEED_ORIG
	
	$CollisionShape3D.disabled = noclip
	
	if not noclip:
		return false
	
	var speed = get_speed() * noclip_speed_mult
	if sprinting:
		speed *= NOCLIP_SPEED_ORIG
	
	self.velocity = cam_aligned_wish_dir * speed
	self.global_position += self.velocity * delta
	
	return true

func _snap_down_stairs_check() -> void:
	var has_snapped = false
	var floor_below : bool = %StairsBelowRayCast3D.is_colliding() and not is_surface_too_steep(%StairsBelowRayCast3D.get_collision_normal())
	var was_on_floor_prev_frame = Engine.get_physics_frames() - _last_frame_on_floor == 1
	
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_prev_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_res = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_res):
			_save_camera_pos()
			var move_y = body_test_res.get_travel().y
			self.position.y += move_y
			apply_floor_snap()
			has_snapped = true
	
	_snapped_to_stairs_last_frame = has_snapped

func _snap_up_stairs_check(delta: float) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame:
		return false
	
	if self.velocity.y > 0 or is_zero_approx((self.velocity * Vector3(1, 0, 1)).length()):
		return false
	
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var body_test_res = PhysicsTestMotionResult3D.new()
	
	if _run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), body_test_res) and body_test_res.get_collider().is_class("StaticBody3D"):
		var step_height = ((step_pos_with_clearance.origin + body_test_res.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (body_test_res.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT:
			return false
		
		%StairsAheadRayCast3D.global_position = body_test_res.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		%StairsAheadRayCast3D.force_raycast_update()
		
		if %StairsAheadRayCast3D.is_colliding() and not is_surface_too_steep(%StairsAheadRayCast3D.get_collision_normal()):
			_save_camera_pos()
			self.global_position = step_pos_with_clearance.origin + body_test_res.get_travel()
			apply_floor_snap()
			return true
	
	return false

func _push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var veloc_diff = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			veloc_diff = max(0, veloc_diff)
			if swimming:
				veloc_diff *= 100
			
			var mass_ratio = min(1.0, WEIGHT / (c.get_collider().mass))
			var push_force = mass_ratio * FORCE
			c.get_collider().apply_impulse(push_dir * veloc_diff * push_force, c.get_position() - c.get_collider().global_position)

func _hold_object() -> void:
	var collider = %Interaction.get_collider()
	#for i in %ShapeCast3D.get_collision_count():
		#var collider = %ShapeCast3D.get_collider(i)
	if collider != null and collider is RigidBody3D:
		held_obj = collider
		(held_obj.find_child("CollisionShape3D") as CollisionShape3D).disabled = true

func _drop_object(throw : float = 0) -> void:
	if held_obj != null:
		(held_obj.find_child("CollisionShape3D") as CollisionShape3D).disabled = false
		var target_pos : Vector3 = %Camera3D.global_transform.origin + (%Camera3D.global_basis * Vector3(0, 0, -2))
		var obj_pos : Vector3 = held_obj.global_transform.origin
		held_obj.linear_velocity = self.velocity
		held_obj.linear_velocity += (target_pos - obj_pos) * (look_speed / (3 + held_obj.mass))
		if not is_zero_approx(throw) :
			held_obj.linear_velocity += (throw / (3 + held_obj.mass)) * (obj_pos - %Camera3D.global_transform.origin)
		
		held_obj = null

func _handle_liquid_physics(delta: float) -> bool:
	if get_tree().get_nodes_in_group("LIQUID").all(func(area: Area3D): return !area.overlaps_body(self)):
		swimming = false
		return false
	
	if not is_on_floor():
		velocity.y -= gravity * 0.1 * delta

	self.velocity += cam_aligned_wish_dir * get_speed() * delta
	
	if Input.is_action_pressed("jump"):
		self.velocity.y -= cam_aligned_wish_dir.y * get_speed() * delta
		self.velocity.y += swim_up_speed * delta
	
	self.velocity = self.velocity.lerp(Vector3.ZERO, delta)
	
	swimming = true
	return true

func _handle_ground_physics(delta: float) -> void:
	_friction(delta)
	_accelerate(delta)
	last_bounce = Vector3.ZERO
	_headbob_effect(delta)

func _handle_air_physics(delta: float) -> void:
	var wish_veloc := wish_dir
	var wish_speed := wish_dir.length()
	
	if wish_speed > max_speed:
		wish_veloc *= (max_speed / wish_speed)
		wish_speed = max_speed
	
	_wall_run(delta)
	
	if is_on_floor() or _snapped_to_stairs_last_frame:
		_friction(delta)
		_accelerate(delta)
		last_bounce = Vector3.ZERO
	else:
		_air_accelerate(wish_veloc, delta)

func _friction(delta) -> void:
	var control = stop_speed if self.velocity.length() < stop_speed else self.velocity.length()
	var new_speed = self.velocity.length() - (control * frict * delta)
	
	new_speed = max(0, new_speed)

	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	
	self.velocity *= new_speed

func _accelerate(delta: float) -> void:
	var cur_speed = self.velocity.dot(wish_dir)
	var add_speed = get_speed() - cur_speed
	
	if add_speed > 0:
		var accel_speed = accel * get_speed() * delta
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * wish_dir

func _air_accelerate(wish_veloc: Vector3, delta: float) -> void:
	self.velocity.y -= gravity * delta
	
	var wish_speed = min(air_move_cap, (air_speed * wish_dir).length())
	var cur_speed = self.velocity.dot(wish_veloc)
	var add_speed = wish_speed - cur_speed
	
	if add_speed > 0:
		var accel_speed = accel * air_speed * delta
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * wish_veloc

func _wall_run(delta: float) -> void:
	if is_on_wall() and sprinting:
		jump_cnt = MAX_JUMPS
		wall_normal = get_slide_collision(0).get_normal()
		
		if Input.is_action_just_pressed("jump") and not wall_normal.is_equal_approx(last_bounce):
			last_bounce = wall_normal
			self.velocity += frict * wall_normal
			self.velocity.y = max_speed * delta
		else:
			self.velocity -= wall_normal
			self.velocity.y += WALLRUN_POWER * delta

@onready var reg_height = %CollisionShape3D.shape.height
func _crouch_uncrouch(delta) -> void:
	var was_crouched = crouching
	if Input.is_action_just_pressed("crouch"):
		if not crouching:
			crouching = true
			#%knife_up.visible = false
			#%knife_down.visible = true
			%sword_up.visible = false
			%sword_down.visible = true
		elif crouching and not self.test_move(self.transform, Vector3(0, CROUCH_DIST, 0)):
			crouching = false
			#%knife_down.visible = false
			#%knife_up.visible = true
			%sword_down.visible = false
			%sword_up.visible = true
	
	var bump_up_if_possible := 0.0
	if was_crouched != crouching and not is_on_floor() and not _snapped_to_stairs_last_frame:
		bump_up_if_possible = CROUCH_JUMP_ADD if crouching else -CROUCH_JUMP_ADD
	
	if not is_zero_approx(bump_up_if_possible):
		var res = KinematicCollision3D.new()
		self.test_move(self.transform, Vector3(0, bump_up_if_possible, 0), res)
		self.position.y += res.get_travel().y
		%Head.position.y -= res.get_travel().y
		%Head.position.y = clampf(%Head.position.y, -CROUCH_DIST, 0)
	
	%Head.position.y = move_toward(%Head.position.y, (-CROUCH_DIST if crouching else 0.0), 7.0 * delta)
	%CollisionShape3D.shape.height = reg_height - CROUCH_DIST if crouching else reg_height
	%CollisionShape3D.position.y = %CollisionShape3D.shape.height / 2
