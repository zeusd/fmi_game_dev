class_name Intelligence
extends Node

var combat: Combat

enum enemy_type {
	KNIGHT
}

enum enemy_state {
	IDLE,
	ALERT,
	SEARCH,
	HUNT,
	FIGHT
}

const REF := "ref"
const STA := "state"
const VIS := "vision"
const NAV := "navigation"

var enemies: Dictionary = {}

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("COMPONENT"):
		if node is Combat:
			combat = node
			break

func activate(id: String, type: enemy_type) -> void:
	if not enemies.has(id):
		var guy = instance_from_id(int(id))
		var new_val: Dictionary = {
			REF: guy as CharacterBody3D,
			STA: enemy_state.IDLE,
			VIS: guy.sight as Sight,
			NAV: guy.nav_agent as NavigationAgent3D
		}
		enemies[id] = new_val

func state_is(id: String) -> enemy_state:
	return enemies[id][STA]

func change_state(id: String, state: enemy_state) -> void:
	enemies[id][STA] = state

func spotted(id: String, body: Node3D) -> void:
	enemies[id][REF].nav_target = body
	enemies[id][STA] = enemy_state.FIGHT
	enemies[id][NAV].target_position = body.global_position

func unspotted(id: String, body: Node3D) -> void:
	enemies[id][REF].look_timer.start(30.0)
	enemies[id][STA] = enemy_state.SEARCH
	enemies[id][NAV].target_position = enemies[id][REF].global_position
