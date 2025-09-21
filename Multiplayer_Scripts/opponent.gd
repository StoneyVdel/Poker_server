extends Node2D

var table_ref

func _ready() -> void:
	table_ref = $"../GameLogic"

func get_players_cards():
	var players = table_ref.players
	var all_player_cards = {}
	for i in players:
		all_player_cards[i] = []
		all_player_cards[i]=table_ref.players_data[i][2]
		
	return all_player_cards

@rpc("authority", "call_remote", "reliable", 0)
func opponent_card_draw(card_count, user):
	pass

@rpc("authority", "call_remote", "reliable", 0)
func show_opponent_hand(players:Array, players_data:Dictionary):
	pass
