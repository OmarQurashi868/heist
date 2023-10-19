extends Node3D
class_name Weapon

var weapon_name: String
var weapon_tier: int
var weapon_attack: Attack
var weapon_owner: Player
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")
enum weapon_type {MELEE, HITSCAN, PROJECTILE}

var is_attacking = false

#func _init(given_name: String, given_tier: int, given_attack: Attack):
	#print("weapon ready")
	#weapon_name = given_name
	#weapon_tier = given_tier
	#weapon_attack = given_attack

func try_deal_damage(target: Player):
	if target.has_method("take_damage")\
	and is_attacking\
	and weapon_owner and target\
	and weapon_owner.team_id != target.team_id:
		target.take_damage(weapon_attack)

func start_attack():
	is_attacking = true
	weapon_attack.knockback_source = weapon_owner.position

func stop_attack():
	is_attacking = false
