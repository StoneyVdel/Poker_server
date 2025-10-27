extends Node

class_name User

const user_card_count = 2

var player_id
var hand = []
var hand_values = []
#var player_data = []
##players_data = { User: [int stake, int player_pot, card_names[string], #card_values[string]] }
#var player_state = []
var is_final_move = false
var is_raising = false
var is_removed = false
var is_folded = false
var has_no_money = false
#players_state = { User: [final_move, needs_to_raise, remove_from_chair, folded] }
var coins = 0
var coins_bet = 0
var initial_bid = 0
var card_values = []

func _ready() -> void:
	pass
	
func set_data(id, coin):
	player_id = id
	coins = coin
	
func set_coins(amount: int):
	coins = amount
	
func get_coins():
	return coins
	
func set_initial_bid(amount: int):
	initial_bid = amount

func set_cards(cards:Array):
	hand = cards
