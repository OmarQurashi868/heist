extends State


func on_enter():
	player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE) 

func phys_proc(_delta):
	player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)
	if !player.animation_tree.get("parameters/swing/active"):
		state_machine.change_state("Base")


func on_exit():
	player.weapon.stop_attack()
