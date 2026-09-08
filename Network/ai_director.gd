#AI Director
extends Node
signal difficulty_changed(modifiers)

var difficulty_score := 0.0
var player_stats := {
	"accuracy": 0.5,
	"damage_taken_recent": 0.0,
	"avg_puzzle_time": 1.0
}

var modifiers := {
	"enemy_aggression": 0.0,
	"puzzle_complexity": 0.0,
	"resource_scarcity": 0.0
}

func update_difficulty(delta):
	var acc = player_stats.accuracy
	var dmg = player_stats.damage_taken_recent
	var solve = player_stats.avg_puzzle_time

	var raw = (acc * 0.4) + ((1.0 - dmg) * 0.3) + ((1.0 - solve) * 0.3)
	difficulty_score = lerp(difficulty_score, raw, 0.1)

	modifiers.enemy_aggression = difficulty_score
	modifiers.puzzle_complexity = difficulty_score
	modifiers.resource_scarcity = difficulty_score

	emit_signal("difficulty_changed", modifiers)
