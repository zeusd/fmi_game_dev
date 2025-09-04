extends Control

const MAIN_MENU:= "res://menus/main_menu.tscn"

func handle_input(enable: bool) -> void:
	self.visible = enable
	self.set_process_input(enable)
	self.set_process_unhandled_input(enable)
	if not enable:
		self.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func in_game() -> void:
	handle_input(false)

func show_value(value: float):
	%Value.text += str(int(value))


func _on_quit_selected() -> void:
	%Quit.label_settings.font_color = Color.DEEP_SKY_BLUE

func _on_quit_unselected() -> void:
	%Quit.label_settings.font_color = Color.BLACK

func _on_quit_held() -> void:
	%Quit.label_settings.font_color = Color.STEEL_BLUE

func _on_quit_pressed() -> void:
	self.get_tree().paused = false
	handle_input(false)
	self.get_tree().change_scene_to_file(MAIN_MENU)


func _on_exit_selected() -> void:
	%Exit.label_settings.font_color = Color.CRIMSON

func _on_exit_unselected() -> void:
	%Exit.label_settings.font_color = Color.BLACK

func _on_exit_held() -> void:
	%Exit.label_settings.font_color = Color.FIREBRICK

func _on_exit_pressed() -> void:
	self.get_tree().quit()
