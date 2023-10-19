extends Node3D
class_name Weapon

var weapon_name: String
var weapon_tier: int
var weapon_attack: Attack
var weapon_owner: Player
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")
enum WEAPON_TYPES {MELEE, HITSCAN, PROJECTILE}
var weapon_type: WEAPON_TYPES
@onready var hitbox: Area3D
var is_attacking = false



func _ready():
	if weapon_type == WEAPON_TYPES.MELEE:
		hitbox = $Area3D
		hitbox.body_entered.connect(hitbox_touched)

func try_deal_damage(target: Player):
	if target\
	and target.has_method("take_damage")\
	and is_attacking\
	and weapon_owner and target\
	and weapon_owner.team_id != target.team_id:
		target.take_damage(weapon_attack)

func start_attack():
	is_attacking = true
	weapon_attack.knockback_source = weapon_owner.position
	if weapon_type == WEAPON_TYPES.HITSCAN:
		shoot_weapon()

func stop_attack():
	if weapon_type == WEAPON_TYPES.MELEE:
		is_attacking = false

func hitbox_touched(body):
	if body.is_in_group("player"):
		try_deal_damage(body)

func shoot_weapon():
	var shooting_target = owner.get_node("RayCast3D").get_collider()
	if shooting_target and shooting_target.is_in_group("player"):
		try_deal_damage(shooting_target)
