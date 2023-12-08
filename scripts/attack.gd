extends Node
class_name Attack

var damage: float
var stun_timer: float
var knockback_force: float
var knockback_source: Vector3


func _init(given_damage = 0, given_stun_timer = 0.5, given_knockback_force = 0, given_knockback_source = Vector3.ZERO):
	damage = given_damage
	stun_timer = given_stun_timer
	knockback_force = given_knockback_force
	knockback_source = given_knockback_source
