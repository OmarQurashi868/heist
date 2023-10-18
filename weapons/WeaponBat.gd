extends Weapon

func _ready():
	weapon_name = "Bat"
	weapon_tier = 0
	weapon_attack = Attack.new(2, 0.5, 0.1, position, 0.5)
	

 
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		melee_attack(body)
