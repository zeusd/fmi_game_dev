class_name Treasure
extends Node

enum loot_type {
	REG,
	SPC
}

var value_all:= 0.0
var value_curr:= 0.0
var loot: Dictionary = {}

const REF:= "ref"
const TYP:= "type"
const VAL:= "value"

func activate(id: String, type: loot_type) -> void:
	if not loot.has(id):
		var lt = instance_from_id(int(id))
		value_all += lt.value
		loot[id] = {
			REF: lt,
			TYP: type,
			VAL: lt.value
		}

func take(id: String) -> void:
	value_curr += loot[id][VAL]
	print_debug(value_curr)
	loot.erase(id)
