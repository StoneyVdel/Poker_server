extends Node

const IP_ADDRESS = "127.0.0.1"
const PORT = 8080
#var multiplayer_scene = preload("res://Scene/multiplayer_player.tscn")
#var _player_spawn_node 
var game_scene = preload("res://Scene/game.tscn")

func start_server():
	
	#get_tree().change_scene_to_packed(game_scene)
	#_player_spawn_node = get_tree().get_current_scene().get_node("Chair2")
	
	print("Starting Host")
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_peer)
	multiplayer.peer_disconnected.connect(_del_player)
	
func join_game():
	print("Joining game")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(IP_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
func _add_player_to_peer(id: int):
	print (" Player %s has joined the game !" % id)

	#var player_to_add = multiplayer_scene.instantiate()
	#player_to_add.player_id = id
	#player_to_add.name = str(id)
	
	#_player_spawn_node.add_child(player_to_add, true)
	
	pass
	
func _del_player(id: int):
	print (" Player %s has left the game !" % id)
	pass
	
	
