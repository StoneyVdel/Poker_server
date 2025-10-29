extends Node

class_name Global

enum GameStages {
	pre, 
	flop, 
	turn, 
	river, 
	showdown
}

enum LastPlayer {
	isLast,
	user
}

var players = []
var user_inst = {}
