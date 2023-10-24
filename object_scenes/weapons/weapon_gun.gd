extends Weapon

func _ready():
	weapon_name = "Pistol"
	weapon_tier = 1
	weapon_attack = weapon_data.pistol_attack
	weapon_type = WEAPON_TYPES.HITSCAN
	is_active = false
	super()
