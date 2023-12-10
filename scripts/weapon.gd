extends Node3D
class_name Weapon

@export var weapon_name: String
@export var weapon_tier: int
@export var cooldown_duration: float
@export var weight: float = 0
@export var can_attack_move: bool = false
@export var animation_name: String
@export var equipped = true

@onready var hitbox: Area3D
var weapon_owner: Player
var weapon_attack: Attack = Attack.new()
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")
var can_attack = true


func _ready():
	weapon_attack = weapon_data.attacks[weapon_name]


func attack():
	pass


func try_deal_damage(target: Player):
	if target\
	and target.has_method("take_damage")\
	and weapon_owner\
	and target != weapon_owner:
		target.take_damage(weapon_attack)


func start_attack():
	weapon_attack.knockback_source = weapon_owner.global_position
	if $AttackSFX:
		$AttackSFX.play()
	start_cooldown()


func start_cooldown():
	can_attack = false
	# FIXME
	get_tree().create_timer(cooldown_duration).timeout.connect(func(): can_attack = true)
	

func stop_attack():
	pass
