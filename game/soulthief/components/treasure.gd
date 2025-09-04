class_name Treasure
extends Node

enum loot_type {
	REG,
	SPC
}

var value_all:= 0.0
var value_curr:= 0.0
var loot: Dictionary = {}
var treasure: Dictionary = {}

const REF:= "ref"
const TYP:= "type"
const VAL:= "value"

@export var player: CharacterBody3D

func _ready() -> void:
	GAME.loot_goal = false
	player.loot = value_curr

func activate(id: String, type: loot_type) -> void:
	if not loot.has(id):
		var lt_ref = instance_from_id(int(id))
		var lt = {
			REF: lt_ref,
			TYP: type,
			VAL: lt_ref.value
		}
		
		loot[id] = lt
		
		if type == loot_type.SPC:
			treasure[id] = lt
		else:
			value_all += lt_ref.value

func take(id: String) -> void:
	if loot[id][TYP] == loot_type.SPC:
		check_steal(id)
		treasure.erase(id)
	else:
		value_curr += loot[id][VAL]
		player.loot = value_curr
		if GAME.difficulty != GAME.dfy.EASY and GAME.check_loot(value_curr / value_all):
			player.loot_done()
	loot.erase(id)

func check_steal(id: String) -> void:
	player.steal(treasure[id][REF])
	if treasure.is_empty():
		GAME.steal_goal = true
		if GAME.difficulty == GAME.dfy.EASY:
			player.game_win()
