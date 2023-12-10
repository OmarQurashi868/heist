extends State


func on_enter():
	player.animation_tree.set("parameters/basejumpfall/transition_request", "fall")

func phys_proc(delta):
	player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
	player.handle_attack()
	
	if player.is_on_floor():
		state_machine.change_state("Base")
