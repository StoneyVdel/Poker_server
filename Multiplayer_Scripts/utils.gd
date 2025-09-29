extends Node

const win_state = true
const loss_state = false

var deck_ref
var player_ref
var game_manager_ref
var hand_node
var room_node
var visuals_ref
var table_ref
var server_ref
var opponent_ref

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	table_ref = $"../Table"
	opponent_ref = $"../Opponent"
	hand_node= load("res://Multiplayer_Scripts/Program.cs").new()
	room_node = load("res://Multiplayer_Scripts/Room.cs").new()
	var _user_handler = load("res://Multiplayer_Scripts/ApplicationUser.cs").new()
	visuals_ref = $"../Visuals"
	server_ref = $".."

func player_constructor(id: int):
	var scene = preload("res://Scene/User.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	set_user_data(id, table_ref.coins, table_ref.increase_amount, instance)
	return instance

func set_user_data(id, coins, increase_amount, instance):
	player_ref.init.rpc_id(id, coins, increase_amount)
	instance.set_data(id, coins)
	
func set_players():
	gv.players = sort_by_turns()
	game_manager_ref.current_user = gv.players[0]
	for i in gv.players:
		gv.user_inst[i] = player_constructor(i)
		gv.user_inst[i].hand = deck_ref.draw_card(2)
		player_ref.set_cards.rpc_id(i, gv.user_inst[i].hand)
		opponent_ref.opponent_card_draw.rpc(2, i)
	

func sort_by_turns():
	var players = []
	var players_all = server_ref.players_id.duplicate()
	var dealer = players_all.pick_random()
	var dealer_index = players_all.find(dealer)
	if dealer_index == players_all.size()-1:
		for player in players_all:
			players.append(player)
	else:
		for i in range(dealer_index+1, players_all.size()):
			players.append(players_all[i])
		for i in range(dealer_index+1):
			players.append(players_all[i])
	
	return players
	
func format_data():
	hand_node.Clear()
	table_ref.reform_table_cards= deck_ref.reformat_cards(table_ref.table_cards, "Table")
	#for i in players_data:
		#players_data[i][gv.PlayerData.player_card_values] = deck_ref.reformat_cards(players_data[i][gv.PlayerData.card_names], i)
	#
	#$"../JSON".to_json(players_data)
	
	hand_node.GetDataFromJSON($"../JSON".json_string)
	hand_node.TestProgram()
	print(hand_node.WinnerNames)
	#var winners = hand_node.WinnerNames
	#game_end(winners)
	
func reset():
	visuals_ref.clear_table.rpc()
	player_ref.disable_user_input.rpc()
	game_manager_ref.current_user = null
	table_ref.table_cards.clear()
	table_ref.table_bets = table_ref.initial_bid
	visuals_ref.set_label.rpc("total_bets_label", table_ref.table_bets)
	game_manager_ref.game_stage = gv.GameStages.pre
	game_manager_ref.start_game()
	
func game_end(winners:Array):
	for id in game_manager_ref.players:
		if winners.find(str(id)) != -1:
			visuals_ref.win_state.rpc_id(id, win_state)
			#players_data[id][gv.PlayerData.player_coins] += round(table_bets / winners.size())
		else :
			visuals_ref.win_state.rpc_id(id, loss_state)
		#visuals_ref.set_label.rpc_id(id, "coin_label", get_bets(id))
	reset()
	
func find_next_user(user):
	var next_user_index = table_ref.players.find(user) + 1
	var next_user
		
	if is_last_player() == false:
		if next_user_index < table_ref.players.size():
			next_user = table_ref.players[next_user_index]
		elif next_user_index == table_ref.players.size():
			next_user = table_ref.players[0]
	if game_manager_ref.User_inst[next_user].is_folded == true:
		find_next_user(next_user)
	else:
		return next_user
		
func check_if_user_valid():
	pass
	
func is_last_player():
	var not_folded_cound = 0
	for user in gv.players:
		if game_manager_ref.user_inst[user].is_folded == true:
			not_folded_cound+=1
	if not_folded_cound == 1:
		return true
	else :
		return false

func get_player_cards():
	pass
	#var players = table_ref.players
	#var all_player_cards = {}
	#for i in players:
		#all_player_cards[i] = []
		#all_player_cards[i]=table_ref.players_data[i][2]
		
	#return all_player_cards
	
