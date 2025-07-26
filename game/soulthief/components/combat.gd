class_name Combat
extends Node

enum fighter_type {
	PLAYER,
	KNIGHT
}

var health : Dictionary = {
	fighter_type.PLAYER: 100,
	fighter_type.KNIGHT: 100
}

var damage : Dictionary = {
	fighter_type.PLAYER: 20,
	fighter_type.KNIGHT: 10
}

const REF := "ref"
const HLT := "health"
const DMG := "damage"

var fighters : Dictionary = {}

func activate(id: String, ftr_type: fighter_type) -> void:
	if not fighters.has(id):
		
		var b = Blood.new()
		
		var ftr = instance_from_id(int(id))
		
		var new_val : Dictionary = {
			REF: ftr,
			HLT: health[ftr_type],
			DMG: damage[ftr_type],
			"bld": b,
			"hitbox": ftr.hitbox,
			"hurtbox": ftr.hurtbox
		}
		
		fighters[id] = new_val
		fighters[id][REF].add_child(b)
		#b.name = "Blood"
		b.global_transform.origin = fighters[id][REF].global_transform.origin + Vector3.UP
		b.emitting = false

func splat(id: String) -> void:
	fighters[id]["bld"].emitting = true
	fighters[id]["bld"].restart()
	fighters[id]["bld"].global_position = fighters[id][REF].global_position + Vector3.UP

func hit(from_id: String, to_id: String) -> void:
	splat(to_id)
	return
	if fighters.has(from_id) and fighters.has(to_id):
		fighters[to_id][HLT] -= fighters[from_id][DMG]
		if fighters[to_id][HLT] <= 0:
			fighters.erase(to_id)
			#fighters[to_id].die()
			
func _kill(id: String) -> void:
	fighters[id][REF].die()
	# blood decal?
