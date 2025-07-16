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

@export var jump_velocity := 3.7
@export var walk_speed := 4.3
@export var sprint_speed := 7.7

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_bounce := Vector3.ZERO
var wall_normal := Vector3.ZERO

const MAX_JUMPS := 2
var jump_cnt := 0
var jump_timer : Timer = Timer.new()
var jump_timeout := jump_velocity / gravity

const MAX_STEP_HEIGHT := 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor := -INF

const CROUCH_DIST = 0.7
const CROUCH_SLOW = 0.8
const CROUCH_JUMP_ADD = CROUCH_DIST * 0.9
var crouching = false

@export var frict := 6.0
@export var accel := 100.0
@export var stop_speed := 100.0
@export var max_speed := 320.0
@export var air_move_cap := 0.85
@export var air_speed := 500.0

var wish_dir := Vector3.ZERO

func get_speed() -> float:
	var speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	return speed * CROUCH_SLOW if crouching else speed

func _ready():
	for child in %PlayerModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)
	
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
			%Camera3D.rotate_x(event.relative.y * y_mouse_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _handle_stick_look_input(delta: float) -> void:
	var target_look = Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
	
	if target_look.length() < cur_stick_look.length():
		cur_stick_look = target_look
	else:
		cur_stick_look = cur_stick_look.lerp(target_look, (1 / stick_look_smoothing) * delta)
	
	rotate_y(-cur_stick_look.x * x_stick_sensitivity)
	%Camera3D.rotate_x(cur_stick_look.y * y_stick_sensitivity)
	%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	

func _headbob_effect(delta: float) -> void:
	headbob_time += self.velocity.length() * delta
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * headbob_frequency * 0.5) * headbob_move,
		sin(headbob_time * headbob_frequency) * headbob_move,
		0
	)

func _process(delta: float) -> void:
	_handle_stick_look_input(delta)
	
	_crouch_uncrouch(delta)
	
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	# mind player look direction for the negations
	wish_dir = self.global_transform.basis * Vector3(-input_dir.x , 0.0, -input_dir.y)
	
	if is_on_floor():
		jump_cnt = 0
		jump_timer.stop()
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	if Input.is_action_pressed("jump") and  jump_cnt < MAX_JUMPS and jump_timer.is_stopped():
		self.velocity.y += jump_velocity * ((jump_cnt / (jump_velocity / MAX_JUMPS)) + 1)
		jump_timer.start(jump_timeout)
		jump_cnt += 1

	move_and_slide()

func _physics_process(delta: float) -> void:
	pass

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
	
	if is_on_floor():
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
	if is_on_wall() and Input.is_action_pressed("sprint"):
		jump_cnt = MAX_JUMPS
		wall_normal = get_slide_collision(0).get_normal()
		if Input.is_action_just_pressed("jump") and not wall_normal.is_equal_approx(last_bounce):
			last_bounce = wall_normal
			self.velocity += frict * wall_normal
			self.velocity.y = max_speed * delta
		else:
			self.velocity -= wall_normal
			self.velocity.y += frict * delta

@onready var reg_height = %CollisionShape3D.shape.height
func _crouch_uncrouch(delta) -> void:
	var was_crouched = crouching
	if Input.is_action_pressed("crouch"):
		crouching = true
	elif crouching and not self.test_move(self.transform, Vector3(0, CROUCH_DIST, 0)):
		crouching = false
	
	var bump_up_if_possible := 0.0
	if was_crouched != crouching and not is_on_floor() and not _snapped_to_stairs_last_frame:
		bump_up_if_possible = CROUCH_JUMP_ADD if crouching else -CROUCH_JUMP_ADD
	
	if not is_zero_approx(bump_up_if_possible):
		var res = KinematicCollision3D.new()
		self.test_move(self.transform, Vector3(0, bump_up_if_possible, 0), res)
		self.position.y += res.get_travel().y
		%Head.position.y -= res.get_travel().y
		%Head.position.y = clampf(%Head.position.y, -CROUCH_DIST, 0)
	
	%Head.position.y = move_toward(%Head.position.y, (-CROUCH_DIST if crouching else 0), 7.0 * delta)
	%CollisionShape3D.shape.height = reg_height - CROUCH_DIST if crouching else reg_height
	%CollisionShape3D.position.y = %CollisionShape3D.shape.height / 2
	
