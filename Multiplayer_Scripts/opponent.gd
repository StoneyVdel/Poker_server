extends Node2D

func _ready() -> void:
	pass

@rpc("authority", "call_remote", "reliable", 0)
func opponent_card_draw(card_count, user):
	pass

@rpc("authority", "call_remote", "reliable", 0)
func show_opponent_hand(players:Array, players_data:Dictionary):
	pass
