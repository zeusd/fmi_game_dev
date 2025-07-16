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
@export var auto_bhop = true
@export var walk_speed := 4.3
@export var sprint_speed := 7.7

var last_bounce := Vector3.ZERO
var wall_normal := Vector3.ZERO
var jump_cnt := 0
var max_jumps := 2
var jump_timer : Timer = Timer.new()
var jump_timeout := jump_velocity / 10

@export var frict := 6.0
@export var accel := 100.0
@export var stop_speed := 100.0
@export var max_speed := 320.0
@export var air_move_cap := 0.85
@export var air_speed := 500.0

var wish_dir := Vector3.ZERO

func get_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

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
	
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	# mind player look direction for the negations
	wish_dir = self.global_transform.basis * Vector3(-input_dir.x , 0.0, -input_dir.y)
	
	if is_on_floor():
		jump_cnt = 0
		jump_timer.stop()
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	if jump_cnt < max_jumps and jump_timer.is_stopped() and (Input.is_action_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump"))):
		self.velocity.y += jump_velocity * ((jump_cnt / (jump_velocity / max_jumps)) + 1)
		jump_timer.start(jump_timeout)
		jump_cnt += 1

	move_and_slide()

func _physics_process(delta: float) -> void:
	pass

func _clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var backoff := self.velocity.dot(normal) * overbounce
	
	if backoff >= 0:
		return
	
	self.velocity -= normal * backoff;

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
		if accel_speed > add_speed:
			accel_speed = add_speed
		self.velocity += accel_speed * wish_dir

func _air_accelerate(wish_veloc: Vector3, delta: float) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var wish_speed = min(air_move_cap, (air_speed * wish_dir).length())
	var cur_speed = self.velocity.dot(wish_veloc)
	var add_speed = wish_speed - cur_speed
	
	if add_speed > 0:
		var accel_speed = accel * air_speed * delta
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * wish_veloc

func _wall_run(delta: float) -> void:
	if is_on_wall() and Input.is_action_pressed("sprint"):
		jump_cnt = max_jumps
		wall_normal = get_slide_collision(0).get_normal()
		if Input.is_action_just_pressed("jump") and !wall_normal.is_equal_approx(last_bounce):
			last_bounce = wall_normal
			self.velocity += frict * wall_normal
			self.velocity.y = max_speed * delta
		else:
			self.velocity -= wall_normal
			self.velocity.y += frict * delta
