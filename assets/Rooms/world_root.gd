extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print("WorldRoot loaded. Server", multiplayer.is_server())
	if multiplayer.is_server():
		$PlayerSpawner.spawn_player(1)
	else:
		rpc_id(1, "request_spawn", multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("authority")
func request_spawn(peer_id: int):
	$PlayerSpawner.spawn_player(peer_id)
