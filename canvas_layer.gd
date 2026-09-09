extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_host_button_pressed():
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(12345)
	multiplayer.multiplayer_peer = peer

	await get_tree().process_frame  # wait one frame
	get_tree().change_scene_to_file("res://assets/Rooms/world_root.tscn")


func _on_join_button_pressed():
	var peer := ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 12345)
	multiplayer.multiplayer_peer = peer

	get_tree().change_scene_to_file("res://WorldRoot.tscn")
