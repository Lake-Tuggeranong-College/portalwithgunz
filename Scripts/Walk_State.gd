class_name WalkState

extends State

func update(delta):
	if Global.player.velocity.length() == 0.0:
		transition.emit("Idle_State")
		print("im_working")
