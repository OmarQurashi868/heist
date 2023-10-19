extends Weapon

func _ready():
	super()
	weapon_name = "GreatSword"
	weapon_tier = 0
	weapon_attack = weapon_data.great_sword
	weapon_type = WEAPON_TYPES.MELEE


