extends State


func on_enter():
	# Play animation
	pass

func phys_proc(delta):
	player.handle_movement(delta)
	
	if player.velocity.y < 0:
		state_machine.change_state("Fall")
	if player.is_on_floor():
		state_machine.change_state("Base")
