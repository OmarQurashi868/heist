extends Resource
class_name WeaponData

#var damage: float
#var stun_timer: float
#var knockback_force: float
#var knockback_source: Vector3

var bat_attack: Attack = Attack.new(2, 0.5, 5, Vector3.ZERO)
var great_sword_attack: Attack = Attack.new(5, 0.9, 10, Vector3.ZERO)
var pistol_attack: Attack = Attack.new(1, 0.1, 0, Vector3.ZERO)
