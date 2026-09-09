extends Node

var rng := RandomNumberGenerator.new()

var all_rooms : Array[PackedScene] = []
var generated_rooms : Array[Node3D] = []
var room_count : int = 5

# NEW: Track where the next room should spawn
var last_room_end : Vector3 = Vector3.ZERO

@onready var room_container : Node3D = $"../RoomContainer"

func _ready():
	print("PG ready is server ", multiplayer.is_server())
	set_process_input(true)
	if multiplayer.is_server():
		rng.randomize()
		load_room_prefabs()
		generate_level()

# NEW: Input handler for T key
func _input(event):
	print("PG input received")
	if event.is_action_pressed("spawn_room"):
		print("T pressed")
		spawn_next_room()

func load_room_prefabs():
	print("Loading rooms from res://assets/Rooms/")
	print("Total rooms loaded:", all_rooms.size())
	var dir := DirAccess.open("res://assets/Rooms/")
	if dir == null:
		print("ERROR: rooms folder not found!")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var scene : PackedScene = load("res://assets/Rooms/" + file_name)
			if scene == null:
				print("FAILED TO LOAD:", file_name)
			else:
				print("Loaded room:", file_name)
				all_rooms.append(scene)
		file_name = dir.get_next()

	print("Total rooms loaded:", all_rooms.size())

func pick_room() -> PackedScene:
	if all_rooms.is_empty():
		push_error("No rooms loaded!")
		return null

	var candidates : Array[PackedScene] = []
	var diff : float = AI_Director.difficulty_score

	for room_scene : PackedScene in all_rooms:
		var inst := room_scene.instantiate()
		var meta := inst.get_node_or_null("Metadata")
		if meta == null:
			push_error("Room missing Metadata: " + room_scene.resource_path)
			inst.queue_free()
			continue

		if meta.difficulty_weight <= diff:
			candidates.append(room_scene)

		inst.queue_free()

	if candidates.is_empty():
		return all_rooms[rng.randi() % all_rooms.size()]

	return candidates[rng.randi() % candidates.size()]

func generate_level():
	var offset := Vector3.ZERO

	for i in range(room_count):
		var room_scene : PackedScene = pick_room()
		if room_scene == null:
			push_error("pick_room() returned null")
			return

		var room := room_scene.instantiate() as Node3D
		if room == null:
			push_error("instantiate() returned null for: " + room_scene.resource_path)
			return

		room.global_transform.origin = offset
		room_container.add_child(room)
		generated_rooms.append(room)

		# Tell clients to spawn the same room
		rpc_spawn_room(room_scene.resource_path, offset)

		var meta := room.find_child("Metadata", true, false)
		if meta == null:
			push_error("Room missing Metadata: " + room.name)
			continue
		offset += meta.room_size

		last_room_end = offset

		populate_room(room)

# NEW: Manual room spawning with T key
func spawn_next_room():
	var room_scene : PackedScene = pick_room()
	var room : Node3D = room_scene.instantiate()

	var position : Vector3

	if generated_rooms.size() == 0:
		position = Vector3.ZERO
	else:
		var prev_room : Node3D = generated_rooms[-1]
		var prev_exit : Transform3D = prev_room.get_node("Connectors/Exit").global_transform
		var new_entry : Transform3D = room.get_node("Connectors/Entry").global_transform
		position = prev_exit.origin - new_entry.origin

	room.global_transform.origin = position
	room_container.add_child(room)
	generated_rooms.append(room)

	# Tell clients to spawn the same room
	rpc_spawn_room(room_scene.resource_path, position)

	populate_room(room)

func populate_room(room : Node3D):
	var meta := room.get_node("Metadata")
	var spawns := room.get_node("SpawnPoints")

	spawn_enemies(spawns.get_node("enemy_spawns"))
	spawn_puzzles(spawns.get_node("puzzle_spawns"))
	spawn_resources(spawns.get_node("resource_spawns"))


func spawn_enemies(enemy_spawns : Node):
	if enemy_spawns.get_child_count() == 0:
		return  # No spawn points, skip

	var aggression : float = AI_Director.modifiers.enemy_aggression
	var count : int = int(lerp(1, 5, aggression))

	var enemy_scene : PackedScene = preload("res://assets/models/enemy.tscn")

	for i in range(count):
		var spawn_point : Node3D = enemy_spawns.get_child(
			rng.randi() % enemy_spawns.get_child_count()
		)

		var enemy : Node3D = enemy_scene.instantiate()
		enemy.global_transform.origin = spawn_point.global_transform.origin
		room_container.add_child(enemy)

func spawn_puzzles(puzzle_spawns : Node):
	if puzzle_spawns.get_child_count() == 0:
		return

	var complexity : float = AI_Director.modifiers.puzzle_complexity

	var spawn_point : Node3D = puzzle_spawns.get_child(
		rng.randi() % puzzle_spawns.get_child_count()
	)

	var puzzle_scene : PackedScene = preload("res://assets/Rooms/puzzles_prefab.tscn")
	var puzzle : Node3D = puzzle_scene.instantiate()

	#puzzle.set_complexity(complexity)
	puzzle.global_transform.origin = spawn_point.global_transform.origin

	room_container.add_child(puzzle)

func spawn_resources(resource_spawns : Node):
	if resource_spawns.get_child_count() == 0:
		return

	var scarcity : float = AI_Director.modifiers.resource_scarcity
	var count : int = int(lerp(5, 1, scarcity))

	var item_scene : PackedScene = preload("res://assets/models/health_pack.tscn")

	for i in range(count):
		var spawn_point : Node3D = resource_spawns.get_child(
			rng.randi() % resource_spawns.get_child_count()
		)

		var item : Node3D = item_scene.instantiate()
		item.global_transform.origin = spawn_point.global_transform.origin
		room_container.add_child(item)

@rpc("authority", "call_local")
func rpc_spawn_room(scene_path: String, position: Vector3):
	var room_scene : PackedScene = load(scene_path)
	var room : Node3D = room_scene.instantiate()
	room.global_transform.origin = position
	room_container.add_child(room)
	generated_rooms.append(room)


func _on_host_button_pressed() -> void:
	pass # Replace with function body.


func _on_join_button_pressed() -> void:
	pass # Replace with function body.
