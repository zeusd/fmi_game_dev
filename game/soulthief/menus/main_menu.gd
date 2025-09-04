extends Control

const LVL_PREP:= "res://menus/prep_screen.tscn"


func _on_start_selected() -> void:
	%Start.label_settings.font_color = Color.WHITE

func _on_start_unselected() -> void:
	%Start.label_settings.font_color = Color.GRAY

func _on_start_button_held() -> void:
	%Start.label_settings.font_color = Color.GOLD

func _on_start_button_pressed() -> void:
	self.get_tree().change_scene_to_file(LVL_PREP)


func _on_quit_selected() -> void:
	%Quit.label_settings.font_color = Color.WHITE

func _on_quit_unselected() -> void:
	%Quit.label_settings.font_color = Color.GRAY

func _on_quit_button_held() -> void:
	%Quit.label_settings.font_color = Color.FIREBRICK
	
func _on_quit_button_pressed() -> void:
	self.get_tree().quit()
