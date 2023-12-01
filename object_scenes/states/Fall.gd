extends State


func on_enter():
	player.animation_tree.set("parameters/Transition/transition_request", "fall")

func phys_proc(delta):
	player.handle_movement(delta)
	player.handle_attack()
	
	if player.is_on_floor():
		state_machine.change_state("Base")
