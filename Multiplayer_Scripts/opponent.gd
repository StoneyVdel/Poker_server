extends Node2D

var player_ref
var table_ref
var visuals_ref
var players
var players_cards = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = $"../Player"
	visuals_ref = $"../Visuals"
	table_ref = $"../GameLogic"
	players = table_ref.players
	
func get_players_cards():
	for i in players:
		players_cards[i] = []
		players_cards[i]=table_ref.players_data[i][2]
		
@rpc("authority", "call_remote", "reliable", 0)
func opponent_card_draw(card_count, user):
	pass
		
		
@rpc("authority", "call_remote", "reliable", 0)
func show_opponent_hand(players:Array, players_data:Dictionary):
	pass
