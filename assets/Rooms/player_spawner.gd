extends Node

@export var player_scene : PackedScene

func spawn_player(peer_id: int):
	if not multiplayer.is_server():
		return
	if player_scene == null:
		push_error("Player scene not assigned!")
		return

	var player := player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	var spawn_point := get_tree().current_scene.get_node_or_null("SpawnPoint")
	if spawn_point:
		player.global_transform.origin = spawn_point.global_transform.origin + Vector3(0, 1.5, 0)
	else:
		player.global_transform.origin = Vector3(0, 2, 0)  # fallback height

	get_tree().current_scene.add_child(player)
	rpc("rpc_spawn_player", peer_id)

@rpc("any_peer", "call_local")
func rpc_spawn_player(peer_id: int):
	if player_scene == null:
		push_error("Player scene not assigned!")
		return

	var player := player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)

	get_tree().current_scene.add_child(player)
