extends Control

var gam:= false;
signal unjournal

func _ready() -> void:
	_dfy_resolve()
	
	_on_easy_unselected()
	_on_usual_unselected()
	_on_hard_unselected()
	
	if gam:
		return
	
	%Steal.label_settings.font_color = Color.BLACK
	%Loot.label_settings.font_color = Color.BLACK
	%Getaway.label_settings.font_color = Color.BLACK
	%Mercy.label_settings.font_color = Color.BLACK
	%Health.label_settings.font_color = Color.BLACK

func _input(event: InputEvent) -> void:
	if not gam:
		return
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("journal"):
		self.get_tree().paused = false
		handle_input(false)
		self.emit_signal("unjournal")

func handle_input(enable: bool) -> void:
	self.visible = enable
	self.set_process_input(enable)
	self.set_process_unhandled_input(enable)
	if not enable:
		self.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func update_goals() -> void:
	if GAME.check_steal():
		%Steal.text = "[+]   Steal The Soulsmith Hammer."
		%Steal.label_settings.font_color = Color.DARK_GREEN
	
	if GAME.loot_goal:
		%Loot.text = "[+]   Collect at least 70% of all loot value."
		%Loot.label_settings.font_color = Color.DARK_GREEN

func in_game() -> void:
	handle_input(false)
	_dfy_resolve()
	gam = true
	
	%ColorRect.color = Color.IVORY * Color(1.0, 1.0, 1.0, 0.7)
	
	%EasyButton.mouse_filter = MOUSE_FILTER_IGNORE
	%Easy.mouse_filter = MOUSE_FILTER_IGNORE
	%UsualButton.mouse_filter = MOUSE_FILTER_IGNORE
	%Usual.mouse_filter = MOUSE_FILTER_IGNORE
	%HardButton.mouse_filter = MOUSE_FILTER_IGNORE
	%Hard.mouse_filter = MOUSE_FILTER_IGNORE
	
	%Steal.label_settings.font_color = Color.BLACK
	%Loot.label_settings.font_color = Color.BLACK
	%Getaway.label_settings.font_color = Color.BLACK
	%Mercy.label_settings.font_color = Color.BLACK
	%Health.label_settings.font_color = Color.BLACK
	
	if GAME.difficulty == GAME.dfy.USUAL:
		return
	
	%Mercy.text = "[+]   Kill no humans."
	%Health.text = "[+]   Sustain no injuries."
	%Mercy.label_settings.font_color = Color.DARK_GREEN
	%Health.label_settings.font_color = Color.DARK_GREEN
	

func _dfy_resolve() -> void:
	%Steal.visible = true
	
	if GAME.difficulty == GAME.dfy.EASY:
		%Loot.visible = false
		%Getaway.visible = false
		%Mercy.visible = false
		%Health.visible = false
		return
	
	%Loot.visible = true
	%Getaway.visible = true
	
	if GAME.difficulty == GAME.dfy.USUAL:
		%Mercy.visible = false
		%Health.visible = false
		return
	
	%Mercy.visible = true
	%Health.visible = true
	


func _on_easy_selected() -> void:
	%Easy.label_settings.font_color = Color.GOLDENROD

func _on_easy_unselected() -> void:
	if GAME.difficulty == GAME.dfy.EASY:
		%Easy.label_settings.font_color = Color.DARK_GOLDENROD
	else:
		%Easy.label_settings.font_color = Color.BLACK

func _on_easy_held() -> void:
	%Easy.label_settings.font_color = Color.DARK_GOLDENROD

func _on_easy_pressed() -> void:
	GAME.difficulty = GAME.dfy.EASY
	
	_on_usual_unselected()
	_on_hard_unselected()
	
	%Steal.visible = true
	%Loot.visible = false
	%Getaway.visible = false
	%Mercy.visible = false
	%Health.visible = false


func _on_usual_selected() -> void:
	%Usual.label_settings.font_color = Color.GOLDENROD

func _on_usual_unselected() -> void:
	if GAME.difficulty == GAME.dfy.USUAL:
		%Usual.label_settings.font_color = Color.DARK_GOLDENROD
	else:
		%Usual.label_settings.font_color = Color.BLACK

func _on_usual_held() -> void:
	%Usual.label_settings.font_color = Color.DARK_GOLDENROD

func _on_usual_pressed() -> void:
	GAME.difficulty = GAME.dfy.USUAL
	
	_on_easy_unselected()
	_on_hard_unselected()
	
	%Steal.visible = true
	%Loot.visible = true
	%Getaway.visible = true
	%Mercy.visible = false
	%Health.visible = false



func _on_hard_selected() -> void:
	%Hard.label_settings.font_color = Color.GOLDENROD

func _on_hard_unselected() -> void:
	if GAME.difficulty == GAME.dfy.HARD:
		%Hard.label_settings.font_color = Color.DARK_GOLDENROD
	else:
		%Hard.label_settings.font_color = Color.BLACK

func _on_hard_held() -> void:
	%Hard.label_settings.font_color = Color.DARK_GOLDENROD

func _on_hard_pressed() -> void:
	GAME.difficulty = GAME.dfy.HARD
	_on_easy_unselected()
	_on_usual_unselected()
	
	%Steal.visible = true
	%Loot.visible = true
	%Getaway.visible = true
	%Mercy.visible = true
	%Health.visible = true
