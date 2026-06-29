class_name Server
var tcp_server
var ready: bool = false
var clients: Dictionary[int, WebSocketPeer] = {}
var tmpUUID: int = 0
var games: Array[Game]

func _init(port: int) -> void:
	print("Initializing...")
	tcp_server = TCPServer.new()
	var err = tcp_server.listen(port)
	if err == OK:
		print("Litsening on port: ", port)
		ready = true
	else:
		print("Failed to initialize")
		
func acceptNewClients() -> void:
	while tcp_server.is_connection_available():
		print("A new client has connected")
		var ws = WebSocketPeer.new()
		ws.accept_stream(tcp_server.take_connection())
		clients[tmpUUID] = ws
		tmpUUID += 1
