extends State


func on_enter():
	player.animation_tree.set("parameters/basejumpfall/transition_request", "base")

func phys_proc(delta):
	player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
	player.handle_jump(delta)
	player.handle_attack()
	
	player.animation_tree.set("parameters/base/blend_position", Vector2(player.side_vector, player.forward_vector / player.SPEED ) )
	
	if not player.is_on_floor():
		if player.velocity.y > 0:
			state_machine.change_state("Jump")
		elif player.velocity.y < 0:
			state_machine.change_state("Fall")
	#else:
		#if player.velocity.x == 0 and player.velocity.z == 0:
			#if player.animation_player.assigned_animation != "idle":
				#player.animation_player.play("idle")
		#else:
			#if player.animation_player.assigned_animation != "run":
				#player.animation_player.play("run")
