extends State


func on_enter():
	# Play animation
	pass

func phys_proc(delta):
	player.handle_movement(delta)
	
	player.handle_jump(delta)
	if player.velocity.y > 0:
		state_machine.change_state("Jump")
	elif player.velocity.y < 0:
		state_machine.change_state("Fall")
