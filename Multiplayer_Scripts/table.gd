extends Node

const game_stage = ["pre", "flop", "turn", "river", "showdown"]
const initial_bid = 0
const user_card_count = 2
const win_state = true
const loss_state = false
const card_values = []
#player_data
const player_coins = 0
const player_pot = 1
const card_names = 2
const player_card_values = 3
#player_state
const is_final_move = 0
const is_raising = 1
const is_removed_from_chair = 2
const is_folded = 3

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
var winners

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
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
	elif dealer_index != players_all.size()-1:
		for i in range(dealer_index+1, players_all.size()):
			players.append(players_all[i])
		for i in range(dealer_index+1):
			players.append(players_all[i])

func init():
	dealer = players_all.pick_random()
	sort_by_turns()
	for i in players:
		player_constructor(i)
		#Is this a good implementation
		if players_data[i][player_coins] < increase_amount :
			multiplayer.multiplayer_peer.disconnect_peer(i)
	if players_data[players[1]][player_coins] > 0:
		table_bet(buyin, players[1] , "Buy-in")
		
func player_constructor(player_id):
	players_data[player_id] = []
	players_state[player_id] = []
	players_data[player_id].insert(player_coins, coins)
	players_data[player_id].insert(player_pot, initial_bid)
	var hand = deck_ref.draw_card(user_card_count)
	player_ref.init.rpc_id(player_id, hand, coins, increase_amount)
	players_data[player_id].insert(card_names, hand)
	#Check if const card_values doesnt bug the game
	players_data[player_id].insert(player_card_values, card_values)
	players_state[player_id].insert(is_final_move, false)
	players_state[player_id].insert(is_raising, false)
	players_state[player_id].insert(is_removed_from_chair, false)
	players_state[player_id].insert(is_folded, false)
	
func table_bet(raise, user, action):
	table_bets+=raise
	players_data[int(user)][player_pot] += raise
	players_data[int(user)][player_coins] -= raise
	player_ref.get_coins(user)
	if action == "Raise" || action == "Buy-in":
		last_bet = raise
		#Send to client
		player_ref.set_raise.rpc(last_bet)
	
		for i in players_state:
			if i != user:
				players_state[i][is_raising] = true
	
	players_state[user][is_raising] = false
	visuals_ref.set_label.rpc("total_bets_label", table_bets)
	
func format_data():
	hand_node.Clear()
	reform_table_cards= deck_ref.reformat_cards(table_cards, "Table")
	for i in players_data:
		players_data[i][player_card_values] = deck_ref.reformat_cards(players_data[i][card_names], i)
	
	$"../JSON".to_json(players_data)
	
	hand_node.GetDataFromJSON($"../JSON".json_string)
	hand_node.TestProgram()
	print(hand_node.WinnerNames)
	winners = hand_node.WinnerNames
	game_end()

func game_end():
	for id in players_data:
		if winners.find(str(id)) != -1:
			visuals_ref.win_state.rpc_id(id, win_state)
			players_data[id][player_coins] += round(table_bets / winners.size())
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
	game_manager_ref.game_stage = "pre"
	game_manager_ref.start_game()

func get_cards(player):
	return players_data[player][card_names]
	
func get_bets(player):
	return players_data[player][player_coins]
