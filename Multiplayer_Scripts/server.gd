extends Control

const IP_ADDRESS = "127.0.0.1"
const PORT = 2055
var peer
var clients_amount = 6
var players = {}
var players_id = []
var player_info = {}
var player_ref
var chair_id = 0
var chair_info = {}
var label_info = {}
var visuals_ref
var table_ref
var game_manager_ref
var new_client_name
var to_timer
var player_count
var min_bid
var coins

func _ready():
	peer = ENetMultiplayerPeer.new()
	if OS.has_feature("dedicated_server"):
		print("starting server")
		start_server()
	#start_server()
	player_ref = $Player
	visuals_ref = $Visuals
	table_ref = $GameLogic
	game_manager_ref = $GameManager
	
func start_server():
	print("Starting Host")
	$Line_log.text = "Starting Host"
	var error = peer.create_server(PORT, clients_amount)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player_to_peer)
	multiplayer.peer_disconnected.connect(_del_player)
	
	table_ref.coins = int($VBoxContainer/HBoxContainer4/CoinAmount.get_line_edit().text)
	table_ref.increase_amount = int($VBoxContainer/HBoxContainer3/MinBet.get_line_edit().text)
	if int($VBoxContainer/HBoxContainer5/BuyIn.get_line_edit().text) < int($VBoxContainer/HBoxContainer4/CoinAmount.get_line_edit().text) && int($VBoxContainer/HBoxContainer5/BuyIn.get_line_edit().text) > 0:
		table_ref.buyin = int($VBoxContainer/HBoxContainer5/BuyIn.get_line_edit().text)
		
	await get_tree().create_timer(1).timeout
	$Line_log.text = "Host has started!"
	
func _add_player_to_peer(id: int):
	print (" Player %s has joined the game !" % id)
	players_id.append(id)
	player_ref.set_player_id.rpc_id(id, id)
	player_ref.get_client_name.rpc_id(id)
	await get_tree().create_timer(1).timeout
	if new_client_name != null:
		add_players_to_table(id)
		if players_id.size() > 1:
			$GameManager.start_game(true)
			visuals_ref.are_analytics_allowed.rpc(bool($VBoxContainer/HBoxContainer6/Analytics.button_pressed))
			visuals_ref.analytics_visible.rpc(bool($VBoxContainer/HBoxContainer6/Analytics.button_pressed))
	pass
	
func _del_player(id: int):
	print (" Player %s has left the game !" % id)
	visuals_ref.clear_chair.rpc(str(id))
	players_id.erase(id)
	chair_id=chair_info.find_key(id)
	chair_info.erase(chair_info.find_key(id))
	table_ref.players_data.erase(id)
	table_ref.players_state.erase(id)
	table_ref.players.erase(id)
	if game_manager_ref.current_user == id && table_ref.players.size() > 1: 
		game_manager_ref.current_user = game_manager_ref.find_next_user(id)
		game_manager_ref.rotation()
	if table_ref.players.size() == 1:
		game_manager_ref.one_player()
		
	if table_ref.players.size() == 0:
		print("Reloading...")
		multiplayer.multiplayer_peer.close()
		get_tree().reload_current_scene()
	pass
	
func add_players_to_table(user_id):
	var next_chair_index
	players[user_id] = new_client_name
	chair_info[chair_id] = user_id
	label_info[chair_id] = new_client_name
	$Visuals.set_chair.rpc(chair_info, label_info)
	if chair_id < 6:
		next_chair_index = chair_id + 1
	else:
		if chair_info.has(null):
			next_chair_index = chair_info.find(null)
		else:
			next_chair_index = 0
	if next_chair_index > chair_info.size():
		chair_id+=1
	else :
		chair_id = chair_info.size()+1

func set_func(add, setting, min=0, max=9999):
	var temp = int(setting.text)
	if add==true && temp < max:
		temp+=1
	elif add==false && temp > min:
		temp-=1
	setting.text = str(temp)

func _on_add_time_pressed() -> void:
	set_func(true, $VBoxContainer/HBoxContainer/TimeoutTime, 0, 60)

func _on_sub_time_pressed() -> void:
	set_func(false, $VBoxContainer/HBoxContainer/TimeoutTime, 0, 60)

func _on_sub_player_pressed() -> void:
	set_func(false, $VBoxContainer/HBoxContainer2/MaxPlayers, 1, 6)


func _on_add_player_pressed() -> void:
	set_func(true, $VBoxContainer/HBoxContainer2/MaxPlayers, 1, 6)


func _on_start_server_pressed() -> void:
	clients_amount = int($VBoxContainer/HBoxContainer2/MaxPlayers.text)
	player_ref.set_timeout_time.rpc(int($VBoxContainer/HBoxContainer/TimeoutTime.text))
	start_server()

func _on_analytics_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		$VBoxContainer/HBoxContainer6/Analytics.text = "On"
	else:
		$VBoxContainer/HBoxContainer6/Analytics.text = "Off"
