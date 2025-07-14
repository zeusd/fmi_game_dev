extends CharacterBody3D

@export var x_mouse_sensitivity : float = 0.006
@export var y_mouse_sensitivity : float = 0.006

@export var x_stick_sensitivity : float = 0.12
@export var y_stick_sensitivity : float = 0.12
@export var stick_look_smoothing : float = 0.3

@export var headbob_move := 0.06
@export var headbob_frequency := 2.4
var headbob_time := 0.0

var _cur_stick_look := Vector2.ZERO

@export var jump_velocity := 5.0
@export var auto_bhop = true
@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 15.0
@export var ground_decel := 10.0
@export var ground_frict := 5.0

@export var air_cap := 0.85
@export var air_accel := 800.0
@export var air_move_speed := 500.0

var wish_dir := Vector3.ZERO

func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _ready():
	for child in %PlayerModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

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
	
	if target_look.length() < _cur_stick_look.length():
		_cur_stick_look = target_look
	else:
		_cur_stick_look = _cur_stick_look.lerp(target_look, (1 / stick_look_smoothing) * delta)
	
	rotate_y(-_cur_stick_look.x * x_stick_sensitivity)
	%Camera3D.rotate_x(_cur_stick_look.y * y_stick_sensitivity)
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

func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var backoff := self.velocity.dot(normal) * overbounce
	
	if backoff >= 0:
		return
	
	self.velocity -= normal * backoff;
	
	# make sure
	var adjust := self.velocity.dot(normal)
	if adjust <= 0.0:
		self.velocity -= normal * backoff;

func _handle_ground_physics(delta: float) -> void:
	var cur_speed = self.velocity.dot(wish_dir)
	var add_speed = get_move_speed() - cur_speed
	
	if add_speed > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		if accel_speed > add_speed:
			accel_speed = add_speed
		self.velocity += accel_speed * wish_dir
	
	var control = ground_decel if self.velocity.length() < ground_decel else self.velocity.length()
	var new_speed = self.velocity.length() - (control * ground_frict * delta)
	
	new_speed = max(0, new_speed)

	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	
	self.velocity *= new_speed
	
	_headbob_effect(delta)

func _handle_air_physics(delta: float) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var cur_speed = self.velocity.dot(wish_dir)
	var wish_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed = wish_speed - cur_speed
	
	if add_speed > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * wish_dir
	
	if is_on_wall():
		#self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		self.velocity.y += 9 * delta
		#clip_velocity(get_wall_normal(), 1, delta)
	else:
		self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	# mind player look direction for the negations
	wish_dir = self.global_transform.basis * Vector3(-input_dir.x , 0., -input_dir.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else :
		_handle_air_physics(delta)
	
	move_and_slide()
