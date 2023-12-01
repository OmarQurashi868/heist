extends State


func on_enter():
	player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE) 

func phys_proc(delta):
	pass


func return_to_base():
	state_machine.change_state("Base")
	print("hello")
