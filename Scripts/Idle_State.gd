class_name IdleState

extends State

@onready var my_label: Label = $"../../Debug/Label"


func update(delta):
	if Global.player.velocity.length() > 0.0:
		transition.emit("WalkState")
		print("hi")
