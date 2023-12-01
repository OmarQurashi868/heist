extends Node
class_name StateMachine

var player: Player
var current_state: State
const DEFAULT_STATE = "Base"


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	player = get_parent() as Player
	current_state = get_node(DEFAULT_STATE) as State


# Called every frame. 'delta' is the elapsed time since the previous frame.
func phys_proc(delta):
	current_state.phys_proc(delta)


func change_state(new_state: String):
	current_state.on_exit()
	current_state = get_node(new_state) as State
	current_state.on_enter()
