extends Node

const initial_bid = 0

var table_cards= []
var big_blind #TB
var small_blind #TB
var dealer

var game_manager_ref
var deck_ref
var player_ref
var visuals_ref

var room_name = "Test Room"
var coins = 100
var buyin = 10
var increase_amount = 1

var table_bets = 0
var last_bet = 0
var reform_table_cards

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	visuals_ref = $"../Visuals"
	
func table_bet(raise, user, action):
	table_bets+=raise
	gv.user_inst[user].coins -= raise
	gv.user_inst[user].coins_bet += raise
	player_ref.get_coins(user)
	
	if action == "Raise" || action == "Buy-in":
		last_bet = raise
		player_ref.set_raise.rpc(last_bet)
		for i in gv.players:
			if i != user:
				gv.user_inst[i].is_raising = true
				gv.user_inst[i].is_final_move = false
	gv.user_inst[int(user)].is_raising = false
	visuals_ref.set_label.rpc("total_bets_label", table_bets)

		
func table_draw(card_count):
	var hand = deck_ref.draw_card(card_count)
	for i in hand:
		table_cards.append(i)
	visuals_ref.draw_card_image.rpc(hand, "Outlines", game_manager_ref.game_stage)
