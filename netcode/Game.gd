class_name Game
var players: Array[Client]
var playerTurnIndex: int

func _init(player1:Client , player2:Client) ->void:
	playerTurnIndex = 0
	players.append(player1)
	players.append(player2)
	pass

func process() -> void:
	for player in players:
		player.ws.poll()
		var state = player.ws.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			var packet = player.ws.get_packet()
		elif state == WebSocketPeer.STATE_CLOSING:
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			pass
