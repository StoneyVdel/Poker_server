extends Node

var action_scene_label
var action_timer
var table_ref
var action_log

func _ready() -> void:
	#action_log = $"../ActionLog"
	table_ref = $"../GameLogic"
	
func action_label_action(action):
	action_scene_label.text = action
	action_scene_label.visible = true
	
	action_timer.start()
	await action_timer.timeout
	action_scene_label.visible = false

@rpc("authority", "call_remote", "reliable", 0)
func cards_to_outline(game_stage: String):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func draw_card_image(hand: Array, node: String):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func add_card_to_hand(card: String, index: int, chair_id: int):
		pass

@rpc("any_peer", "call_remote", "reliable", 0)
func set_label(label: String, text: String):
	pass
		
@rpc("authority", "call_remote", "reliable", 0)
func update_action_log(action: String):
	pass
	#action_log.text += str(action, "\n")

@rpc("any_peer", "call_remote", "reliable", 0)
func set_chair(chair_info: Dictionary):
	for id in chair_info:
		print("Chair :", id, "for user : ", chair_info[id])

@rpc("any_peer", "call_remote", "reliable", 0)
func win_state(state: bool):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func clear_chair(user: String):
	table_ref.players.erase(user)
	table_ref.player_data.erase(user)
