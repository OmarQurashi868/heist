extends Weapon
class_name WeaponHitscan

@export var ammo = 10


func attack():
	if equipped and can_attack and ammo > 0:
		shoot_weapon()


func shoot_weapon():
	start_attack()
	var shooting_target = owner.get_node("AimRay").get_collider()
	$MuzzleFlash.emitting = true
	if shooting_target and shooting_target.is_in_group("player"):
		try_deal_damage(shooting_target)
