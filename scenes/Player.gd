extends CharacterBody3D
class_name Player

@onready var game_manager: Node3D = $"../GameManager"
@onready var anim: AnimationPlayer = $AnimationPlayer
var player_id = 0
var team_id
const FULL_HEALTH = 10.0
@export var health = 10.0
@export var weapon: Weapon
const RESPAWN_TIMER = 1
const SPEED = 8.0
const JUMP_VELOCITY = 15.0
const ROTATION_SPEED = 1.5
const GRAVITY_FACTOR = 4.0
var has_money = false
var is_stunned = false
var is_dead = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	weapon = $WeaponGun
	weapon.weapon_owner = self

func _physics_process(delta):
	# Add the gravity.
	if Input.is_action_just_pressed("attack"):
		weapon.start_attack()
		anim.play("attack_melee")
		
	if not is_on_floor():
		velocity.y -= gravity * delta * GRAVITY_FACTOR

	# Handle Jump.
	if not is_dead:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var move_dir = Input.get_axis("ui_down", "ui_up")
		var rot_dir = Input.get_axis("ui_left", "ui_right")
		
		var direction = Vector2.from_angle(rotation.y)
		if is_stunned:
			direction = Vector2.ZERO
		velocity.x = move_toward(velocity.x, -direction.y * SPEED * move_dir, SPEED)
		velocity.z = move_toward(velocity.z, -direction.x * SPEED * move_dir, SPEED)
		rotation.y += -rot_dir * delta * ROTATION_SPEED
	
	move_and_slide()


func take_damage(attack: Attack):
	if not is_dead and not is_stunned:
		if has_money:
			game_manager.drop_bag()
		health -= attack.damage
		velocity = (position - attack.knockback_source) * attack.knockback_force
		is_stunned = true
		get_tree().create_timer(attack.stun_timer).timeout.connect(func(): is_stunned = false)
		if health <= 0:
			die()
	

func die():
	velocity = Vector3.ZERO
	is_dead = true
	get_tree().create_timer(RESPAWN_TIMER).timeout.connect(func(): game_manager.respawn_player(self))

func stop_attack():
	weapon.stop_attack()
