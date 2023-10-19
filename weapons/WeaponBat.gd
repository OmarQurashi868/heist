extends Weapon

func _ready():
	weapon_name = "WeaponBat"
	weapon_tier = 0
	weapon_attack = weapon_data.bat_attack

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		try_deal_damage(body)
