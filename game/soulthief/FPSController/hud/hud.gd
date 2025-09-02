extends Control

@export var player: CharacterBody3D
var coin_gem_timeout:= Timer.new()

func _ready() -> void:
	self.add_child(coin_gem_timeout)
	coin_gem_timeout.one_shot = true
	
	coin_gem_timeout.timeout.connect(_hide_coin_gem)

func _process(delta: float) -> void:
	%Mana.material.set_shader_parameter("fill_percent", (3.0 * player.blink_cost - player.mana_timer.time_left) / (3.0 * player.blink_cost))
	if player.mana_timer.time_left < 2.0 * player.blink_cost:
		%Spell.material.set_shader_parameter("active", player.casting)
		%Spell.material.set_shader_parameter("passive", false)
	else:
		%Spell.material.set_shader_parameter("active", false)
		%Spell.material.set_shader_parameter("passive", true)
		%Spell.material.set_shader_parameter("dont", player.casting)

func update_health() -> void:
	%Health.material.set_shader_parameter("fill_percent", player.health / player.max_health)

func update_loot() -> void:
	%Coin.visible = true
	%Loot.text = str(int(player.loot))
	coin_gem_timeout.start(5.0)

func _hide_coin_gem() -> void:
	%Coin.visible = false
