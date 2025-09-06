class_name Combat
extends Node

@export var player: CharacterBody3D

enum fighter_type {
	PLAYER,
	KNIGHT
}

static var health: Dictionary = {
	fighter_type.PLAYER: 100.0,
	fighter_type.KNIGHT: 100.0
}

static var damage: Dictionary = {
	fighter_type.PLAYER: 10.0,
	fighter_type.KNIGHT: 10.0
}

const REF:= "ref"
const HLT:= "health"
const DMG:= "damage"
const BLD:= "blood"
const TYP:= "type"
const HIT:= "hitbox"
const HUR:= "hurtbox"

var fighters: Dictionary = {}

func activate(id: String, ftr_type: fighter_type) -> void:
	if not fighters.has(id):
		var b = Blood.new()
		var ftr = instance_from_id(int(id)) as Node3D
		
		var new_val: Dictionary = {
			REF: ftr,
			HLT: health[ftr_type],
			DMG: damage[ftr_type],
			BLD: b,
			TYP: ftr_type,
			HIT: ftr.hitbox,
			HUR: ftr.hurtbox
		}
		
		fighters[id] = new_val
		fighters[id][REF].add_child(b)
		b.global_position = fighters[id][REF][HUR].global_position
		b.emitting = false
		
		if fighters[id][TYP] == fighter_type.PLAYER:
			fighters[id][REF].health = fighters[id][HLT]

func splat(id: String) -> void:
	fighters[id][BLD].emitting = true
	fighters[id][BLD].restart()

func bloodstain(id: String) -> void:
	var decal = Bloodstain.new()
	fighters[id][REF].add_child(decal)
	decal.global_position = fighters[id][HUR].global_position

func hit(from_id: String, to_id: String) -> void:
	if fighters.has(from_id) and fighters.has(to_id):
		var dmg_mod = 1.0
		var weak_mod = 1.0
		
		if fighters[to_id][HLT] <= 0:
			return
		
		if fighters[from_id][TYP] == fighter_type.PLAYER:
			dmg_mod = fighters[from_id][REF].mod_dmg()
		
		if fighters[to_id][TYP] == fighter_type.KNIGHT:
			weak_mod = fighters[to_id][REF].mod_weak()
			
			if (weak_mod < 5.0 and dmg_mod < 0.0) or (weak_mod == 1.0 and dmg_mod == 0.0):
				fighters[to_id][REF].bonked()
				return
			
			if fighters[to_id][REF].nap:
				fighters[to_id][HLT] = 0
				fighters[to_id].dead = true
				splat(to_id)
				bloodstain(to_id)
				return
		
		fighters[to_id][HLT] -= fighters[from_id][DMG] * (dmg_mod / weak_mod)
		fighters[to_id][REF].hit_by(fighters[from_id][REF])
		if dmg_mod > 0.0:
			splat(to_id)
		if fighters[to_id][TYP] == fighter_type.PLAYER:
			fighters[to_id][REF].health = fighters[to_id][HLT]
			if GAME.difficulty == GAME.dfy.HARD:
				player.game_over()
		if fighters[to_id][HLT] <= 0:
			_kill(to_id, fighters[from_id][TYP] == fighter_type.PLAYER)

func area_damage(from_area: Area3D, damage: float, to_id: String) -> void:
	if fighters.has(to_id):
		fighters[to_id][HLT] -= damage
		splat(to_id)
		if fighters[to_id][TYP] == fighter_type.PLAYER:
			fighters[to_id][REF].health = fighters[to_id][HLT]
			if GAME.difficulty == GAME.dfy.HARD:
				player.game_over()
		if fighters[to_id][HLT] <= 0:
			_kill(to_id, false)

func _kill(id: String, player_caused: bool) -> void:
	fighters[id][REF].die()
	bloodstain(id)
	if GAME.difficulty == GAME.dfy.HARD and player_caused and fighters[id][TYP] != fighter_type.PLAYER:
		player.game_over()
