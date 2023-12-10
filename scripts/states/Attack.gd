extends State


func on_enter():
	player.animation_tree.set("parameters/weapon_anim/transition_request", player.weapon.animation_name)
	player.animation_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE) 

func phys_proc(delta):
	if player.weapon.can_attack_move:
		player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
	else:
		player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)
	
	if !player.animation_tree.get("parameters/attack/active"):
		state_machine.change_state("Base")


func on_exit():
	player.weapon.stop_attack()
