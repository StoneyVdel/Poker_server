extends Node

var json_string

func to_json(data):
	json_string = JSON.stringify(data)
	
	print(json_string)
	#var file = FileAccess.open("res://Scripts/player_data.JSON", FileAccess.WRITE)
	#file.store_string(json_string)
	#file.close()
