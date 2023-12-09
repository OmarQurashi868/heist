extends Weapon
class_name WeaponMelee


func _ready():
	super()
	hitbox = $Area3D as Area3D
	hitbox.body_entered.connect(hitbox_touched)
	hitbox.monitoring = false


func attack():
	if equipped and can_attack:
		start_attack()


func start_attack():
	super()
	hitbox.monitoring = true


func stop_attack():
	hitbox.monitoring = false


func hitbox_touched(body):
	if body.is_in_group("player"):
		try_deal_damage(body)
