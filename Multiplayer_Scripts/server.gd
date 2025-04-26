extends Node

var peer = ENetMultiplayerPeer.new()
const IP_ADDRESS = "127.0.0.1"
const PORT = 1492
const MAX_CLIENTS = 6
var players = {}
var players_id = []
var player_info = {"name": "Name"}
var player_ref
var chair_id = 0
var chair_info = {}

func _ready():
	if OS.has_feature("dedicated_server"):
		print("starting server")
		start_server()
	start_server()
	multiplayer.peer_connected.connect(_add_player_to_peer)
	multiplayer.peer_disconnected.connect(_del_player)
	player_ref = $Player
	
func start_server():
	print("Starting Host")
	#var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	
	multiplayer.peer_connected.connect(_add_player_to_peer)
	multiplayer.peer_disconnected.connect(_del_player)
	
func _add_player_to_peer(id: int):
	print (" Player %s has joined the game !" % id)
	players_id.append(id)
	player_ref.set_player_id.rpc_id(id, id)
	add_players_to_table(id)
	chair_id+=1
	if players_id.size() > 1:
		$GameManager.start_game(true)
	pass
	
func _del_player(id: int):
	print (" Player %s has left the game !" % id)
	
	pass
	
func add_players_to_table(user_id):
	chair_info[chair_id] = user_id
	$Visuals.set_chair.rpc(chair_info)
