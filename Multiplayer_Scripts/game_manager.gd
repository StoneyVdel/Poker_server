extends Node

var current_user = null
var deck_ref
var table_ref
var temp_timer = null
var game_stage = gv.GameStages.pre
var opponent_ref
var visuals_ref
var player_ref
var player_ids
var server_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../DeckLogic"
	table_ref = $"../GameLogic"
	opponent_ref = $"../Opponent"
	visuals_ref = $"../Visuals"
	player_ref = $"../Player"
	server_ref = $".."
	temp_timer = Timer.new()
	temp_timer.one_shot = true
	temp_timer.set_wait_time(6)
	temp_timer.connect("timeout", on_timeout)
	add_child(temp_timer)

func on_timeout():
	table_ref.table_cards.clear()
	start_game()
	
func start_game():
	table_ref.players_all = server_ref.players_id.duplicate()
	player_ref.disable_user_input.rpc()
	await get_tree().create_timer(1).timeout
	if table_ref.players_all.size() > 1:
		table_ref.init()
		rotation()

func one_player():
	player_ref.disable_user_input.rpc()
	var winners = [str(current_user)]
	table_ref.game_end(winners)

func rotation():
	var state_check = true
	check_if_remove()
	
	if is_last_player() == true:
		one_player()
		
	for i in table_ref.players_state:
		if table_ref.get_user_data(gv.UserDataType.state, i, gv.PlayerStates.is_final_move) == false:
			state_check = false
			
	if state_check == true:
		var stage_index = game_stage
		game_stage+=1
		stage_set()
		
		if game_stage == gv.GameStages.flop:
			table_ref.table_draw(3)
		elif game_stage == gv.GameStages.turn:
			table_ref.table_draw(1)
		elif game_stage == gv.GameStages.river:
			table_ref.table_draw(1)
		elif game_stage == gv.GameStages.showdown:
			table_ref.format_data()
			var all_player_cards = opponent_ref.get_players_cards()
			opponent_ref.show_opponent_hand.rpc(table_ref.players, all_player_cards)
	else : 
		if (table_ref.players_data[current_user][gv.PlayerData.player_coins] != 0 && \
			table_ref.players_state[current_user][gv.PlayerStates.is_folded] == false):
				player_ref.user_turn.rpc_id(int(current_user), \
				table_ref.players_state[current_user][gv.PlayerStates.is_raising], table_ref.last_bet)
		else:
			#if table_ref.players_data[current_user][gv.PlayerData.player_coins] == 0:
				#no_money()
			#else:
				find_next_user(current_user)

func check_if_remove():
	for i in table_ref.players_state:
		if table_ref.players_state[i][gv.PlayerStates.is_removed_from_chair] == true:
			visuals_ref.clear_chair(str(i))

func stage_set():
	for i in table_ref.players_state:
		table_ref.players_state[i][gv.PlayerStates.is_final_move] = false

func is_last_player():
	var not_folded_cound = 0
	for user in table_ref.players_state:
		if table_ref.players_state[user][gv.PlayerStates.is_folded]:
			not_folded_cound+=1
	if not_folded_cound == 1:
		return true
	else :
		return false
		
#This code needs to be checked for bugs
#func no_money():
	#var has_coins = 0
	#for i in table_ref.players_data:
		#if table_ref.get_bets(i) == 0:
			#has_coins+=1
	#if has_coins == table_ref.players_data.size():
		#for i in table_ref.players_state:
			#table_ref.players_state[i][gv.PlayerStates.is_final_move] = true
		#game_stage+=1
		#rotation()

func find_next_user(user):
	var next_user_index = table_ref.players.find(user) + 1
	var next_user
		
	if is_last_player() == false:
		if next_user_index < table_ref.players.size():
			next_user = table_ref.players[next_user_index]
		elif next_user_index == table_ref.players.size():
			next_user = table_ref.players[0]
	else:
		rotation()
		return
	if table_ref.players_state[next_user][gv.PlayerStates.is_folded] == true:
		find_next_user(next_user)
	else:
		current_user = next_user
		return
