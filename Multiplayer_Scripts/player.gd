extends Node2D

var deck_ref
var table_ref
var game_manager_ref
var visuals_ref
var opponent_ref
var server_ref

var timeout_timer
var current_raise
var player_cards
@export var coins = 100
@export var player_id : int
var increase_amount
var utils_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visuals_ref = $"../Visuals"
	#timeout_timer = $"../TimeoutTimer"
	opponent_ref = $"../Opponent"
	table_ref = $"../Table"
	game_manager_ref = $"../GameManager"
	server_ref = $".."
	utils_ref = $"../Utils"
	increase_amount = table_ref.increase_amount

@rpc("authority", "call_remote", "reliable", 0)
func set_timeout_time(time: int):
	pass

@rpc("authority","call_remote", "reliable", 0)
func add_players_to_table(user_id, chair_id):
	opponent_ref.opponent_card_draw(2, user_id, chair_id)
	
@rpc("authority", "call_remote", "reliable", 0)
func set_player_id(id: int):
	pass

@rpc("authority", "call_remote", "reliable", 0)
func get_client_name():
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func send_client_name(client_name: String):
	server_ref.new_client_name = client_name
	print(client_name)
	
@rpc("authority", "call_remote", "reliable",0)
func init(player_cards: Array, coins: int, increase_amount: int):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func get_coins(player_id:int):
	var coin = gv.user_inst[player_id].coins
	set_coins.rpc_id(player_id, coin)
	
@rpc("authority", "call_remote", "reliable", 0)
func set_coins(coins:int):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func user_turn(raise_check: bool, last_bet:int):
	pass

@rpc("authority", "call_remote", "reliable", 0)
func set_increase_amount(increase_amount):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func folded(player_id:int):
	gv.user_inst[player_id].is_folded = true

@rpc("authority", "call_remote", "reliable", 0)
func set_raise():
	pass

@rpc("authority", "call_remote", "reliable", 0)
func set_cards(cards):
	pass
	
@rpc("any_peer", "call_remote", "reliable", 0)
func user_raise(user_id: int, raise: int, action: String):
	table_ref.table_bet(raise, user_id, action)
	#coins = table_ref.get_bets(user_id)
	
@rpc("any_peer", "call_remote", "reliable", 0)
func server_end_move(user_id: int, action:String):
	gv.user_inst[user_id].is_final_move = true
	game_manager_ref.current_user = utils_ref.find_next_user(game_manager_ref.current_user)
	visuals_ref.update_action_log.rpc(str(server_ref.label_info[server_ref.chair_info.find_key(user_id)], " ", action))
	game_manager_ref.rotation()

@rpc("authority", "call_remote", "reliable", 0)
func disable_user_input():
	pass
