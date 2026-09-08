# RoomLibrary.gd
extends Node

var rng := RandomNumberGenerator.new()
var all_rooms : Array[PackedScene] = []
var generated_rooms := []
var room_count := 5

@onready var room_container := $"../RoomContainer"

func _ready():
	rng.randomize()
	load_room_prefabs()
	generate_level()


func load_room_prefabs():
	var dir := DirAccess.open("res://rooms/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var scene = load("res://rooms/" + file_name)
				all_rooms.append(scene)
			file_name = dir.get_next()

func pick_room() -> PackedScene:
	var candidates : Array[PackedScene] = []
	var diff := AI_Director.difficulty_score

	for room_scene : PackedScene in all_rooms:
		var inst = room_scene.instantiate()
		var meta = inst.get_node("Metadata")
		inst.queue_free()

		if meta.difficulty_weight <= diff:
			candidates.append(room_scene)

	if candidates.is_empty():
		return all_rooms[rng.randi() % all_rooms.size()]

	return candidates[rng.randi() % candidates.size()]


func generate_level():
	var offset := Vector3.ZERO

	for i in range(room_count):
		var room_scene : PackedScene = pick_room()
		var room : Node3D = room_scene.instantiate()

		room.global_transform.origin = offset
		room_container.add_child(room)
		generated_rooms.append(room)

		offset += room.get_node("Metadata").room_size
		populate_room(room)

func populate_room(room):
	var meta = room.get_node("Metadata")
	var spawns = room.get_node("SpawnPoints")

	spawn_enemies(spawns.enemy_spawns)
	spawn_puzzles(spawns.puzzle_spawns)
	spawn_resources(spawns.resource_spawns)

func spawn_enemies(enemy_spawns):
	var count := int(lerp(1, 5, AI_Director.modifiers.enemy_aggression))
	#var enemy_scene : PackedScene = preload("res://enemies/basic_enemy.tscn")

	for i in range(count):
		var spawn_point = enemy_spawns.get_child(rng.randi() % enemy_spawns.get_child_count())
		#var enemy : Node3D = enemy_scene.instantiate()
		#enemy.global_transform.origin = spawn_point.global_transform.origin
		#room_container.add_child(enemy)

func spawn_puzzles(puzzle_spawns):
	var complexity : float = AI_Director.modifiers.puzzle_complexity

	var spawn_point = puzzle_spawns.get_child(rng.randi() % puzzle_spawns.get_child_count())
	#var puzzle_scene : PackedScene = preload("res://puzzles/puzzle_prefab.tscn")
	#var puzzle : Node3D = puzzle_scene.instantiate()

	#puzzle.set_complexity(complexity)
	#puzzle.global_transform.origin = spawn_point.global_transform.origin
#
	#room_container.add_child(puzzle)

func spawn_resources(resource_spawns):
	var scarcity : float = AI_Director.modifiers.resource_scarcity
	var count : int = int(lerp(5, 1, scarcity))

	#var item_scene : PackedScene = preload("res://items/health_pack.tscn")

	for i in range(count):
		var spawn_point : Node3D = resource_spawns.get_child(
			rng.randi() % resource_spawns.get_child_count()
		)

		#var item : Node3D = item_scene.instantiate()
		#item.global_transform.origin = spawn_point.global_transform.origin
		#room_container.add_child(item)
