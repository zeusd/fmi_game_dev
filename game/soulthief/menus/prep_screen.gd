extends Control

const MAIN_MENU:= "res://menus/main_menu.tscn"
const LVL_1:= "res://levels/lvl_1.tscn"

var lvl: PackedScene

func _ready() -> void:
	lvl = load(LVL_1)


func _on_next_selected() -> void:
	%Next.label_settings.font_color = Color.GOLDENROD

func _on_next_unselected() -> void:
	%Next.label_settings.font_color = Color.BLACK

func _on_next_held() -> void:
	%Next.label_settings.font_color = Color.DARK_GOLDENROD

func _on_next_pressed() -> void:
	GAME.lvl = GAME.levels.LVL_1
	GAME.prepare_level()
	
	if lvl != null:
		get_tree().change_scene_to_packed(lvl)
		return
	get_tree().change_scene_to_file(LVL_1)


func _on_back_selected() -> void:
	%Back.label_settings.font_color = Color.DEEP_SKY_BLUE

func _on_back_unselected() -> void:
	%Back.label_settings.font_color = Color.BLACK

func _on_back_held() -> void:
	%Back.label_settings.font_color = Color.STEEL_BLUE

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
