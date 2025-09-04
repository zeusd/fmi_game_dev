extends Control

const MAIN_MENU:= "res://menus/main_menu.tscn"
const LVL_PREP:= "res://menus/prep_screen.tscn"

signal unpause
var deathscreen:= false

func _ready() -> void:
	_on_continue_unselected()
	_on_restart_unselected()
	_on_try_unselected()
	_on_quit_unselected()
	_on_exit_unselected()
	%Paused.label_settings.font_color = Color.WHITE
	handle_input(false)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_continue_pressed()

func handle_input(enable: bool) -> void:
	self.visible = enable
	self.set_process_input(enable)
	self.set_process_unhandled_input(enable)
	if not enable:
		self.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func game_over() -> void:
	deathscreen = true
	%ColorRect.color = Color.RED * Color(1.0, 1.0, 1.0, 0.3)
	%Continue.label_settings.font_color = Color.DIM_GRAY
	%Continue.mouse_filter = MOUSE_FILTER_IGNORE
	%ContinueButton.mouse_filter = MOUSE_FILTER_IGNORE
	%Paused.text = "Mission Failed"
	%Paused.label_settings.font_color = Color.BLACK


func _on_continue_selected() -> void:
	%Continue.label_settings.font_color = Color.WHITE

func _on_continue_unselected() -> void:
	%Continue.label_settings.font_color = Color.GRAY

func _on_continue_held() -> void:
	%Continue.label_settings.font_color = Color.GOLD

func _on_continue_pressed() -> void:
	if deathscreen:
		return
	self.get_tree().paused = false
	handle_input(false)
	self.emit_signal("unpause")

func _on_restart_selected() -> void:
	%Restart.label_settings.font_color = Color.WHITE

func _on_restart_unselected() -> void:
	%Restart.label_settings.font_color = Color.GRAY

func _on_restart_held() -> void:
	%Restart.label_settings.font_color = Color.PALE_GOLDENROD

func _on_restart_pressed() -> void:
	self.get_tree().paused = false
	handle_input(false)
	GAME.prepare_level()
	self.get_tree().reload_current_scene()


func _on_try_selected() -> void:
	%Try.label_settings.font_color = Color.WHITE

func _on_try_unselected() -> void:
	%Try.label_settings.font_color = Color.GRAY

func _on_try_held() -> void:
	%Try.label_settings.font_color = Color.PALE_GOLDENROD

func _on_try_pressed() -> void:
	self.get_tree().paused = false
	handle_input(false)
	self.get_tree().change_scene_to_file(LVL_PREP)


func _on_quit_selected() -> void:
	%Quit.label_settings.font_color = Color.WHITE

func _on_quit_unselected() -> void:
	%Quit.label_settings.font_color = Color.GRAY

func _on_quit_held() -> void:
	%Quit.label_settings.font_color = Color.PALE_GOLDENROD

func _on_quit_pressed() -> void:
	self.get_tree().paused = false
	handle_input(false)
	self.get_tree().change_scene_to_file(MAIN_MENU)


func _on_exit_selected() -> void:
	%Exit.label_settings.font_color = Color.WHITE

func _on_exit_unselected() -> void:
	%Exit.label_settings.font_color = Color.GRAY

func _on_exit_held() -> void:
	%Exit.label_settings.font_color = Color.FIREBRICK

func _on_exit_pressed() -> void:
	self.get_tree().quit()
