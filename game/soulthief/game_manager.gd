class_name GameManager
extends Node

# Common inverse scale. Calculated as 1.0 / Inverse Scale Factor. 
# Used to help translate properties using Quake Units into Godot Units.
const INVERSE_SCALE: float = 0.03125

enum {
	WORLD_LAYER = (1 << 0),
	ACTOR_LAYER = (1 << 1),
	TRIGGER_LAYER = (1 << 2)
}

var steal_goal:= false
var difficulty:= dfy.USUAL
enum dfy {
	EASY,
	USUAL,
	HARD
}

var loot_goal:= false
var lt_thld: Dictionary = {
	dfy.EASY: 0.0,
	dfy.USUAL: 0.7,
	dfy.HARD: 0.7
}

var lvl: levels
enum levels {
	LVL_1
}

var lvl_1_stl: Dictionary = {}
enum treasures {
	NULL,
	LVL_1_HAMMER
}

func prepare_level() -> void:
	steal_goal = false
	loot_goal = false
	match lvl:
		levels.LVL_1:
			lvl_1_stl[treasures.LVL_1_HAMMER] = false

func steal(trs: treasures) -> void:
	match lvl:
		levels.LVL_1:
			lvl_1_stl[trs] = true

func check_steal() -> bool:
	match lvl:
		levels.LVL_1:
			for thing in lvl_1_stl.keys():
				if lvl_1_stl[thing] == false:
					return false
			steal_goal = true
			return true
	return false

func check_loot(percent: float) -> bool:
	loot_goal = percent >= lt_thld[difficulty]
	return loot_goal

func resolve_treasure(trs_name: String) -> treasures:
	match trs_name:
		"lvl_1_hammer":
			return treasures.LVL_1_HAMMER
		_:
			return treasures.NULL

func use_targets(activator: Node, target: String, new_activator: Node = null) -> void:
	# Targetnames are really Godot Groups, so we can have multiple entities 
	# share a common "targetname" in Trenchbroom.
	var target_list: Array[Node] = get_tree().get_nodes_in_group(target)
	for targ in target_list:
		var f: String
		# Be careful when specifying a function since we can't pass arguments 
		# to it (without hackarounds of course)
		if 'targetfunc' in activator:
			f = activator.targetfunc
		if f.is_empty():
			f = "use"
		if targ.has_method(f):
			targ.activator = activator if new_activator == null else new_activator
			targ.call(f)

func set_targetname(node: Node, targetname: String) -> void:
	if node != null and not targetname.is_empty():
		node.add_to_group(targetname)

# Converts Quake 1 axis to Godot axis
static func id_vec_to_godot_vec(vec: Variant)->Vector3:
	var org: Vector3 = Vector3.ZERO
	if vec is Vector3:
		org = vec
	elif vec is String:
		var arr: PackedFloat64Array = (vec as String).split_floats(" ")
		for i in max(arr.size(), 3):
			org[i] = arr[i]
	return Vector3(org.y, org.z, org.x)
