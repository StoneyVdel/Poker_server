extends Node

var current_user = null
var temp_timer = null
var game_stage = gv.GameStages.pre
var players_all = []

var deck_ref
var table_ref
var opponent_ref
var visuals_ref
var player_ref
var player_ids
var server_ref
var utils_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../DeckLogic"
	table_ref = $"../Table"
	opponent_ref = $"../Opponent"
	visuals_ref = $"../Visuals"
	player_ref = $"../Player"
	server_ref = $".."
	utils_ref = $"../Utils"
	#temp_timer = Timer.new()
	#temp_timer.one_shot = true
	#temp_timer.set_wait_time(6)
	#temp_timer.connect("timeout", on_timeout)
	#add_child(temp_timer)

func on_timeout():
	table_ref.table_cards.clear()
	start_game()
	
func start_game():
	player_ref.disable_user_input.rpc()
	#await get_tree().create_timer(1).timeout
	#Temp
	utils_ref.set_players()
	table_ref.table_bet(table_ref.buyin, gv.players[1] , "Buy-in")
	player_ref.user_turn.rpc_id(int(current_user), \
		gv.user_inst[current_user].is_raising, table_ref.last_bet)
	rotation()
	
func one_player(user):
	player_ref.disable_user_input.rpc()
	var winners = [user]
	print(winners)
	utils_ref.game_end(winners)

func rotation():
	var state_check = true
	check_if_remove()
	
	#Check if all players are folded
	var last_user_check = utils_ref.is_last_player()
	if last_user_check[0] == true :
		state_check=false
		one_player(last_user_check[1])
		
	for i in gv.players:
		if  gv.user_inst[i].is_final_move == false:
			state_check = false

	#Move game stage
	if state_check == true:
		@warning_ignore("int_as_enum_without_cast")
		game_stage+=1
		#stage_set()
		if game_stage == gv.GameStages.flop:
			table_ref.table_draw(3)
		elif game_stage == gv.GameStages.turn:
			table_ref.table_draw(1)
		elif game_stage == gv.GameStages.river:
			table_ref.table_draw(1)
		elif game_stage == gv.GameStages.showdown:
			#fix
			utils_ref.format_data()
			var all_player_cards = utils_ref.get_player_cards()
			opponent_ref.show_opponent_hand.rpc(gv.players, all_player_cards)
		rotated()

func rotated():
	for i in gv.players:
		gv.user_inst[i].is_final_move = false
		
func check_if_remove():
	for i in gv.players:
		if gv.user_inst[i].is_removed == true:
			visuals_ref.clear_chair(str(i))
	pass

func check_states():
	pass
	
#func stage_set():
	#for i in table_ref.players_state:
		#table_ref.players_state[i][gv.PlayerStates.is_final_move] = false

		
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
