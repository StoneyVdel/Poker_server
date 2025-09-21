extends Node

class_name Global

enum GameStages {
	pre, 
	flop, 
	turn, 
	river, 
	showdown
}
enum PlayerData {
	player_coins, 
	player_pot, 
	card_names, 
	player_card_values
}

enum PlayerStates {
	is_final_move, 
	is_raising, 
	is_removed_from_chair, 
	is_folded
}

enum UserDataType {
	data,
	state
}
