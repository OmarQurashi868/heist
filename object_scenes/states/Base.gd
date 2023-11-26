extends State


func on_enter():
	player.animation_player.play("idle")

func phys_proc(delta):
	player.handle_movement(delta)
	player.handle_jump(delta)
	
	if not player.is_on_floor():
		if player.velocity.y > 0:
			state_machine.change_state("Jump")
		elif player.velocity.y < 0:
			state_machine.change_state("Fall")
	else:
		if player.velocity.x == 0 and player.velocity.z == 0:
			if player.animation_player.assigned_animation != "idle":
				player.animation_player.play("idle")
		else:
			if player.animation_player.assigned_animation != "run":
				player.animation_player.play("run")
