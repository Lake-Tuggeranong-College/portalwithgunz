extends State

class_name IdleState

func enter():
	print("entering idle state")

func handle_input(event: InputEvent):
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		state_machine.change_state("walkstate")
	elif Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumpstate") 
