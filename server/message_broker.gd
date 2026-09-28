class_name MessageBroker

static func send(player_session: PlayerSession, rpc_func: Callable, args: Array = []):
	if player_session != null && player_session.is_status_set(enums.ConnectionStatus.Connected):
		var _args: Array
		_args.assign(args)
		_args.push_front(player_session.peer_id)
		rpc_func.callv(_args)

static func broadcast(sessions: Array[PlayerSession], rpc_func: Callable, args: Array = []):
	for player_session in sessions:
		send(player_session, rpc_func, args)
