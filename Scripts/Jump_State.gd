extends State

class_name JumpState

var JUMP_SPEED = 400
func enter():
	var character = state_machine.get_parent()
	character.velocity.y = -JUMP_SPEED

func physics_update(delta):
	var character = state_machine.get_parent()


	# Apply gravity
	character.velocity.y += 980 * delta

	# Handle horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * 200

	character.move_and_slide()

	# Return to appropriate state when landing
	if character.is_on_floor():
		if direction != 0:
			state_machine.change_state("walk")
		else:
			state_machine.change_state("idle")
