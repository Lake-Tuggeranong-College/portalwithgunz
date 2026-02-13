extends State

class_name WalkState

func physcis_update(delta):
	var character = state_machine.get_parent()
	var direction = Input.get_axis("move_left", "move_right")

	if direction == 0:
		state_machine.change_state("idlestate")
		return
	
	character.velocity.x = direction * 200
	character.move_and_slide()

func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumpstate")
