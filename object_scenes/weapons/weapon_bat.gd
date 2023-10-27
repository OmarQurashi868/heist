extends Weapon

func _ready():
	weapon_name = "Bat"
	weapon_tier = 0
	weapon_attack = weapon_data.bat_attack
	cooldown_duration = weapon_data.bat_cooldown
	animation_name = weapon_data.bat_animation
	weapon_type = WEAPON_TYPES.MELEE
	#is_active = false
	super()

