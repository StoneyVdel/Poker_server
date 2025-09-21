extends Node

const initial_bid = 0
const user_card_count = 2
const win_state = true
const loss_state = false
const card_values = []

var players_all
var players = []
var players_data = {}
#players_data = { User: [int stake, int player_pot, card_names[string], #card_values[string]] }
var players_state = {}
#players_state = { User: [final_move, needs_to_raise, remove_from_chair, folded] }
var table_cards= []
var big_blind #TB
var small_blind #TB
var dealer

var game_manager_ref
var deck_ref
var player_ref
var visuals_ref
var server_ref
var opponent_ref

var room_name = "Test Room"
var coins = 100
var buyin = 10
var increase_amount = 1

var table_bets = 0
var last_bet = 0
var hand_node
var reform_player_cards = []
var reform_table_cards
var room_node 

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	opponent_ref = $"../Opponent"
	hand_node= load("res://Multiplayer_Scripts/Program.cs").new()
	room_node = load("res://Multiplayer_Scripts/Room.cs").new()
	var _user_handler = load("res://Multiplayer_Scripts/ApplicationUser.cs").new()
	visuals_ref = $"../Visuals"
	server_ref = $".."
	
func sort_by_turns():
	var dealer_index = players_all.find(dealer)
	if dealer_index == players_all.size()-1:
		for player in players_all:
			players.append(player)
	else:
		for i in range(dealer_index+1, players_all.size()):
			players.append(players_all[i])
		for i in range(dealer_index+1):
			players.append(players_all[i])

func init():
	dealer = players_all.pick_random()
	sort_by_turns()
	game_manager_ref.current_user = players[0]
	for i in players:
		player_constructor(i)
		opponent_ref.opponent_card_draw.rpc(2, i)
		#Is this a good implementation
		if players_data[i][gv.PlayerData.player_coins] < increase_amount :
			multiplayer.multiplayer_peer.disconnect_peer(i)
	if players_data[players[1]][gv.PlayerData.player_coins] > 0:
		table_bet(buyin, players[1] , "Buy-in")
		
func player_constructor(player_id):
	players_data[player_id] = []
	players_state[player_id] = []
	players_data[player_id].insert(gv.PlayerData.player_coins, coins)
	players_data[player_id].insert(gv.PlayerData.player_pot, initial_bid)
	var hand = deck_ref.draw_card(user_card_count)
	player_ref.init.rpc_id(player_id, hand, coins, increase_amount)
	players_data[player_id].insert(gv.PlayerData.card_names, hand)
	players_data[player_id].insert(gv.PlayerData.player_card_values, card_values)
	players_state[player_id].insert(gv.PlayerStates.is_final_move, false)
	players_state[player_id].insert(gv.PlayerStates.is_raising, false)
	players_state[player_id].insert(gv.PlayerStates.is_removed_from_chair, false)
	players_state[player_id].insert(gv.PlayerStates.is_folded, false)
	
func table_bet(raise, user, action):
	table_bets+=raise
	players_data[int(user)][gv.PlayerData.player_pot] += raise
	players_data[int(user)][gv.PlayerData.player_coins] -= raise
	player_ref.get_coins(user)
	if action == "Raise" || action == "Buy-in":
		last_bet = raise
		player_ref.set_raise.rpc(last_bet)
	
		for i in players_state:
			if i != user:
				players_state[i][gv.PlayerStates.is_raising] = true
				players_state[i][gv.PlayerStates.is_final_move] = false
	
	players_state[user][gv.PlayerStates.is_raising] = false
	visuals_ref.set_label.rpc("total_bets_label", table_bets)
	
func format_data():
	hand_node.Clear()
	reform_table_cards= deck_ref.reformat_cards(table_cards, "Table")
	for i in players_data:
		players_data[i][gv.PlayerData.player_card_values] = deck_ref.reformat_cards(players_data[i][gv.PlayerData.card_names], i)
	
	$"../JSON".to_json(players_data)
	
	hand_node.GetDataFromJSON($"../JSON".json_string)
	hand_node.TestProgram()
	print(hand_node.WinnerNames)
	var winners = hand_node.WinnerNames
	game_end(winners)

func game_end(winners:Array):
	for id in players_data:
		if winners.find(str(id)) != -1:
			visuals_ref.win_state.rpc_id(id, win_state)
			players_data[id][gv.PlayerData.player_coins] += round(table_bets / winners.size())
		else :
			visuals_ref.win_state.rpc_id(id, loss_state)
		visuals_ref.set_label.rpc_id(id, "coin_label", get_bets(id))
	reset()

func reset():
	visuals_ref.clear_table.rpc()
	player_ref.disable_user_input.rpc()
	players.clear()
	players_data.clear()
	players_state.clear()
	game_manager_ref.current_user = null
	table_cards.clear()
	table_bets = initial_bid
	visuals_ref.set_label.rpc("total_bets_label", table_bets)
	game_manager_ref.game_stage = gv.GameStages.pre
	game_manager_ref.start_game()

func get_user_data(data_type:int, user_index: int, data_index : int):
	match data_type:
		gv.UserDataType.data:
			return players_data[user_index][data_index]
		gv.UserDataType.state:
			return players_state[user_index][data_index]
		
func table_draw(card_count):
	var hand = deck_ref.draw_card(card_count)
	for i in hand:
		table_cards.append(i)
	visuals_ref.draw_card_image.rpc(hand, "Outlines", game_manager_ref.game_stage)
	game_manager_ref.rotation()
	
func get_cards(player):
	return players_data[player][gv.PlayerData.card_names]
	
func get_bets(player):
	return players_data[player][gv.PlayerData.player_coins]
