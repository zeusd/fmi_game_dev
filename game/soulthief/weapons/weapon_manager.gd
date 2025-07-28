class_name WeaponManager
extends Node3D

@export var player: CharacterBody3D
@export var look_raycast: RayCast3D

@export var view_model_container: Node3D

@export var curr_r: WeaponResource
@export var curr_l: WeaponResource

var curr_r_view: Node3D
var curr_l_view: Node3D

@export var allow_attack: bool = true

#@onready var audio_stream_player: = $AudioStreamPlayer3D

const ANIM_P := "AnimationPlayer"

func _ready() -> void:
	update_weapon_model()

func update_weapon_model() -> Array[Node3D]:
	var rl: Array[Node3D]
	if view_model_container != null:
		if curr_r != null and curr_r.view_model:
			if curr_r_view:
				view_model_container.remove_child(curr_r_view)
			curr_r.weapon_manager = self
			curr_r_view = curr_r.view_model.instantiate()
			curr_r_view.name = curr_r.wep_name
			view_model_container.add_child(curr_r_view)
			curr_r_view.position = curr_r.pos
			curr_r_view.rotation = curr_r.rot
			curr_r.is_eqipped = true
			rl.append(curr_r_view)
		if curr_l != null and curr_l.view_model:
			if curr_l_view:
				view_model_container.remove_child(curr_l_view)
			curr_l.weapon_manager = self
			curr_l_view = curr_l.view_model.instantiate()
			curr_l_view.name = curr_l.wep_name
			view_model_container.add_child(curr_l_view)
			curr_l_view.position = curr_l.pos
			curr_l_view.rotation = curr_l.rot
			curr_l.is_eqipped = true
			rl.append(curr_l_view)
	return rl

func managed_input(event: InputEvent) -> void:
	if is_inside_tree():
		if curr_r != null and event.is_action_pressed("attack") and allow_attack:
			curr_r.on_strike()

func queue_anim(wep: WeaponResource, anim_name: String) -> void:
	var anim_player
	if wep == curr_r:
		anim_player = curr_r_view.get_node_or_null(ANIM_P)
	elif wep == curr_l:
		anim_player = curr_l_view.get_node_or_null(ANIM_P)
	if not anim_player or not anim_player.has_animation(name):
		return
	else:
		anim_player.queue(anim_name)

func play_anim(wep: WeaponResource, anim_name: String) -> void:
	var anim_player
	if wep == curr_r:
		anim_player = curr_r_view.get_node_or_null(ANIM_P)
	elif wep == curr_l:
		anim_player = curr_l_view.get_node_or_null(ANIM_P)
	if not anim_player or not anim_player.has_animation(anim_name):
		return
	else:
		anim_player.clear_queue()
		anim_player.seek(0.0)
		anim_player.play(anim_name)
	

func get_anim(wep: WeaponResource) -> String:
	var anim_player
	if wep == curr_r:
		anim_player = curr_r_view.get_node_or_null(ANIM_P)
	elif wep == curr_l:
		anim_player = curr_l_view.get_node_or_null(ANIM_P)
	
	if not anim_player:
		return ""
	return anim_player.current_animation

#func play_sound(sound: AudioStream) -> void:
	#if sound:
		#if audio_stream_player.stream != sound:
			#audio_stream_player.stream = sound
		#audio_stream_player.play()
#
#func stop_sound() -> void:
	#audio_stream_player.stop()
