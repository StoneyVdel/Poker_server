extends Node2D

var deck_ref
var table_ref
var game_manager_ref
var visuals_ref
var opponent_ref

var timeout_timer
var current_raise
var player_cards
@export var coins = 100
@export var player_id : int
var increase_amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visuals_ref = $"../Visuals"
	#timeout_timer = $"../TimeoutTimer"
	opponent_ref = $"../Opponent"
	table_ref = $"../GameLogic"
	game_manager_ref = $"../GameManager"
	increase_amount = table_ref.increase_amount
	
@rpc("authority","call_remote", "reliable", 0)
func add_players_to_table(user_id, chair_id):
	opponent_ref.opponent_card_draw(2, user_id, chair_id)
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func set_player_id(id: int):
	player_id=id

@rpc("authority", "call_remote", "reliable",0)
func init(player_cards: Array, coins: int, increase_amount: int):
	print("Initializing")
	
	#Getting card images for the player cards
	#visuals_ref.draw_card_image(player_cards, "Player")
	#visuals_ref.set_label(visuals_ref.coin_label, coins)

@rpc("any_peer", "call_remote", "reliable", 0)
func get_coins(player_id:int):
	var coin = table_ref.get_bets(player_id)
	print(coins)
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
	table_ref.players.erase(player_id)

@rpc("authority", "call_remote", "reliable", 0)
func set_raise():
	pass
	
@rpc("any_peer", "call_remote", "reliable", 0)
func user_raise(user_id: int, raise: int, action: String):
	table_ref.table_bet(raise, user_id, action)
	coins = table_ref.get_bets(user_id)
	table_ref.reset_user_state()
	
@rpc("any_peer", "call_remote", "reliable", 0)
func server_end_move(user_id: int, action:String):
	print("END MOVE SERVER", " User ID : ", user_id)
	table_ref.players_state[game_manager_ref.current_user][0] = true
	game_manager_ref.current_user = game_manager_ref.find_next_user(user_id)
	visuals_ref.update_action_log.rpc(str(user_id, " ", action))
	game_manager_ref.rotation()

@rpc("authority", "call_remote", "reliable", 0)
func disable_user_input():
	pass
