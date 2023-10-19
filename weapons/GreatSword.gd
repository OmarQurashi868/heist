extends Weapon

func _ready():
	weapon_name = "GreatSword"
	weapon_tier = 1
	weapon_attack = weapon_data.great_sword_attack
	#weapon_type = WEAPON_TYPES.MELEE
	super()


