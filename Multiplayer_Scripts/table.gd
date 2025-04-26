extends Node

const game_stage = ["pre", "flop", "turn", "river", "showdown"]

var players_all
var players = []
var players_data = {}
#players_data = { User: [int stake, int player_pot, card_names[string], #card_values[string]] }
var players_state = {}
#players_state = { User: [user_state, needs_to_raise] }
var table_cards= []
var big_blind #TB
var small_blind #TB
var dealer
var game_manager_ref
var deck_ref
var coins = 100
var increase_amount = 1
var table_bets = 0
var last_bet = 0
var hand_node
var room_name = "Test Room"
var reform_player_cards = []
var reform_table_cards
var room_node
var winners
var player_ref
var visuals_ref

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	hand_node= load("res://Multiplayer_Scripts/Program.cs").new()
	room_node = load("res://Multiplayer_Scripts/Room.cs").new()
	var _user_handler = load("res://Multiplayer_Scripts/ApplicationUser.cs").new()
	visuals_ref = $"../Visuals"
	
func sort_by_turns():
	var dealer_index = players_all.find(dealer)
	players.clear()
	if dealer_index == players_all.size()-1:
		for player in players_all:
			players.append(player)
	elif dealer_index != players_all.size()-1:
		for i in range(dealer_index+1, players_all.size()):
			players.append(players_all[i])
		for i in range(dealer_index+1):
			players.append(players_all[i])

#Initiating game: dealing cards
func init(is_new_game):
	players_all = $"..".players_id.duplicate()
	print(players_all)
	dealer = players_all.pick_random()
	print(dealer)
	sort_by_turns()
	var card_count = 2
	#var j = 0
	for i in players:
		if is_new_game == true:
			#creating a array for the player data
			players_data[i] = []
			players_state[i] = []
			players_data[i].insert(0, coins)
			players_data[i].insert(1, 0)
			var hand = deck_ref.draw_card(card_count)
			player_ref.init.rpc_id(i, hand, coins, increase_amount)
			players_data[i].insert(2, hand)
			players_data[i].insert(3, [])
			players_state[i].insert(0, false)
			players_state[i].insert(1, false)
			players_state[i].insert(2, false)
		else:
			var hand = deck_ref.draw_card(card_count)
			players_data[i][1] = 0
			players_data[i][2].clear()
			players_data[i][3].clear()
			player_ref.init.rpc_id(i, hand, players_data[i][0], increase_amount)
			players_data[i][2] = hand
			players_state[i][0]=false
			players_state[i][1]=false
			players_state[i][2]=false
		print(i, players_data[i])
		print(" ", players)
		#deck_ref.chairs[j].get_node("Label").text = str(i)
		#j+=1

#Resets players state for the next game stage
func reset_user_state():
	for i in players_data:
		players_state[i][0] = false
		
func table_bet(raise, user, action):
	table_bets+=raise
	print(user)
	players_data[int(user)][1] += raise
	players_data[int(user)][0] -= raise
	player_ref.get_coins(user)
	if action == "Raise":
		last_bet = raise
		#Send to client
		player_ref.set_raise.rpc(last_bet)
	
		for i in players_state:
			if i != user:
				players_state[i][1] = true
	
	players_state[user][1] = false
	visuals_ref.set_label.rpc("total_bets_label", table_bets)
	
func format_data():
	reform_table_cards= deck_ref.reformat_cards(table_cards, "Table")
	for i in players_data:
		players_data[i][3] = deck_ref.reformat_cards(players_data[i][2], i)
	
	$"../JSON".to_json(players_data)
	
	hand_node.GetDataFromJSON($"../JSON".json_string)
	hand_node.TestProgram()
	print(hand_node.WinnerNames)
	winners = hand_node.WinnerNames
	game_end(true)
	
	pass

func game_end(are_players):
	if are_players == true:
		for id in players:
			if winners.find(str(id)) != -1:
				visuals_ref.win_state.rpc_id(id, 1)
				players_data[id][0] += (table_bets / winners.size())
			else :
				visuals_ref.win_state.rpc_id(id, 0)
			visuals_ref.set_label.rpc_id(id, "coin_label", get_bets(id))
	else:
		visuals_ref.win_state.rpc(0)
		visuals_ref.win_state.rpc_id(players[0], 1)
		players_data[players[0]][0]+=table_bets
		visuals_ref.set_label.rpc_id(players[0], "coin_label", get_bets(players[0]))
	table_bets = 0
	visuals_ref.set_label.rpc("total_bets_label", table_bets)
	game_manager_ref.game_stage = "pre"
	game_manager_ref.temp_timer.set_wait_time(6)
	game_manager_ref.temp_timer.start()
	await game_manager_ref.temp_timer.timeout
	table_cards.clear()
	game_manager_ref.start_game(false)
	
func get_cards(player):
	return players_data[player][2]
	
func get_bets(player):
	return players_data[player][0]
