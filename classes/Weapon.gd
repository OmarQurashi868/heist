extends Node3D
class_name Weapon

var weapon_name: String
var weapon_tier: int
var weapon_attack: Attack
var cooldown_duration: float
var animation_name: String
var weapon_owner: Player
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")
enum WEAPON_TYPES {MELEE, HITSCAN, PROJECTILE}
var weapon_type: WEAPON_TYPES
@onready var hitbox: Area3D
var is_attacking = false
var is_active = true
var can_attack = true



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
	if is_active and not is_attacking and can_attack and animation_name:
		weapon_owner.anim.play(animation_name)
		is_attacking = true
		weapon_attack.knockback_source = weapon_owner.position
		if weapon_type == WEAPON_TYPES.HITSCAN:
			shoot_weapon()
		if $AttackSFX:
			$AttackSFX.play()
		start_cooldown()

func stop_attack():
	if weapon_type == WEAPON_TYPES.MELEE:
		is_attacking = false

func hitbox_touched(body):
	if body.is_in_group("player"):
		try_deal_damage(body)

func shoot_weapon():
	var shooting_target = owner.get_node("AimRay").get_collider()
	$MuzzleFlash.emitting = true
	if shooting_target and shooting_target.is_in_group("player"):
		try_deal_damage(shooting_target)
		
		
func start_cooldown():
	can_attack = false
	get_tree().create_timer(cooldown_duration).timeout.connect(func(): can_attack = true)
	print(cooldown_duration)
	

