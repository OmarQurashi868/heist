extends Node3D
class_name Weapon

var weapon_name: String
var weapon_tier: int
var weapon_attack: Attack
var weapon_owner: Player
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")
enum WEAPON_TYPES {MELEE, HITSCAN, PROJECTILE}
var weapon_type: WEAPON_TYPES
@onready var hitbox: Area3D = $Area3D
var is_attacking = false



func _ready():
	if weapon_type == WEAPON_TYPES.MELEE:
		hitbox.body_entered.connect(hitbox_touched)

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
	

func hitbox_touched(body):
	if body.is_in_group("player"):
		try_deal_damage(body)
