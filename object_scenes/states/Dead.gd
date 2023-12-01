extends State


func on_enter():
	player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.animation_tree.set("parameters/hurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	player.animation_tree.set("parameters/dead/transition_request", "dead")
	$DeathSFX.play()
	player.is_stunned = true


func phys_proc(delta):
	player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)


func on_exit():
	player.is_stunned = false
