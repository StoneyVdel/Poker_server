extends Node

var current_user
var deck_ref
var table_ref
var temp_timer = null
#var action_timer
var game_stage = "pre"
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
	start_game(false)
	
func start_game(is_new_game):
	print("Starting game...", is_new_game)
	table_ref.players = server_ref.players_id.duplicate()
	current_user = null
	player_ref.disable_user_input.rpc()
	await get_tree().create_timer(1).timeout
	if table_ref.players.size() > 1:
		table_ref.init(is_new_game)
		opponent_draw()
		current_user = table_ref.players[0]
		rotation()
	
func  opponent_draw():
	for user in table_ref.players:
		opponent_ref.opponent_card_draw.rpc(2, user)
		pass

func one_player():
	player_ref.disable_user_input.rpc()
	for i in table_ref.players_state:
		table_ref.players_state[i][0] = true
	table_ref.reset()
	

func rotation():
	var state_check = true
	check_if_remove()
	print("table cards: ", table_ref.table_cards)
	
	if table_ref.players.size() == 1:
		one_player()
		
	for i in table_ref.players_state:
		if table_ref.players_state[i][0] == false || table_ref.players_state[i][3] == true:
			state_check = false
			
	if state_check == true:
		var stage_index = table_ref.game_stage.find(game_stage)
		game_stage = table_ref.game_stage[stage_index+1]
		table_ref.reset_user_state()
		print(game_stage)
		
		if game_stage == "flop":
			visuals_ref.cards_to_outline.rpc(game_stage)
			table_draw(3)
		elif game_stage == "turn":
			visuals_ref.cards_to_outline.rpc(game_stage)
			table_draw(1)
		elif game_stage == "river":
			visuals_ref.cards_to_outline.rpc(game_stage)
			table_draw(1)
		elif game_stage == "showdown":
			table_ref.format_data()
			opponent_ref.get_players_cards()
			opponent_ref.show_opponent_hand.rpc(table_ref.players, opponent_ref.players_cards)
			pass
	else : 
		if table_ref.players_data[current_user][0] != 0 && table_ref.players_state[current_user][3] == false:
			print("Current_user:", current_user, " ",table_ref.players_state[current_user][1], " ", table_ref.last_bet)
			player_ref.user_turn.rpc_id(int(current_user), table_ref.players_state[current_user][1], table_ref.last_bet)
		else:
			if table_ref.players_data[current_user][0] == 0:
				no_money()
			else:
				find_next_user(current_user)

func check_if_remove():
	for i in table_ref.players_state:
		if table_ref.players_state[i][2] == true:
			visuals_ref.clear_chair(i)

func no_money():
	var has_coins = 0
	for i in table_ref.players_data:
		if table_ref.get_bets(i) == 0:
			has_coins+=1
	if has_coins == table_ref.players_data.size():
		for i in table_ref.players_state:
			table_ref.players_state[i][0] = true
		game_stage=table_ref.game_stage[table_ref.game_stage.find(game_stage)+1]
		rotation()


func table_draw(card_count):
	var hand = deck_ref.draw_card(card_count)
	for i in hand:
		table_ref.table_cards.append(i)
	
	visuals_ref.draw_card_image.rpc(hand, "Outlines")
		
	rotation()


func find_next_user(user):
	var next_user_index = table_ref.players.find(user) + 1
	var next_user
	var not_folded = 0
	var nfold_user
	for i in table_ref.players:
		if table_ref.players_state[i][3] == false:
			not_folded += 1
			nfold_user = i
			
	if not_folded <= 1:
		table_ref.players_data[nfold_user][0] += round(table_ref.table_bets)
		table_ref.reset()
		
	if table_ref.players.size() > 1:
		if next_user_index < table_ref.players.size():
			next_user = table_ref.players[next_user_index]
		else :
			next_user = table_ref.players[0]
			
	return next_user
