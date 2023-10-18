extends Node3D
class_name Weapon

var weapon_name: String
var weapon_tier: int
var weapon_attack: Attack

func _init(given_name: String, given_tier: int, given_attack: Attack):
	weapon_name = given_name
	weapon_tier = given_tier
	weapon_attack = given_attack

func deal_damage(target: Player):
	if target.has_method("take_damage"):
		target.take_damage(weapon_attack)

func melee_attack(target):
	deal_damage(target)
