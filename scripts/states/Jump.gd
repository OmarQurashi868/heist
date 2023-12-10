extends State


func on_enter():
	player.animation_tree.set("parameters/basejumpfall/transition_request", "jump")

func phys_proc(delta):
	player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
	player.handle_attack()
	
	if player.velocity.y < 0:
		state_machine.change_state("Fall")
	if player.is_on_floor():
		state_machine.change_state("Base")
