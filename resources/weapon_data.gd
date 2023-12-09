extends Resource
class_name WeaponData

var attacks = {
	"bat": Attack.new(2, 0.5, 1, Vector3.ZERO),
	"sword": Attack.new(5, 0.9, 10, Vector3.ZERO),
	"pistol": Attack.new(1, 0.1, 0, Vector3.ZERO)
	}

var cooldowns = {
	"bat": 0.65,
	"sword": 0.65,
	"pistol": 0.65
}

var anims = {
	"bat": "attack_melee",
	"sword": "",
	"pistol": ""
}
