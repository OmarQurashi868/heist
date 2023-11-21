extends State


func on_enter():
	player.animation_player.play("fall")

func phys_proc(delta):
	player.handle_movement(delta)
	
	if player.is_on_floor():
		state_machine.change_state("Base")
