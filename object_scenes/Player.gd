extends CharacterBody3D
class_name Player

@onready var game_manager: Node3D = $"../GameManager"
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var aimray = $AimRay
@onready var state_machine = $StateMachine as StateMachine
@onready var animation_player = $weasel/AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationTree as AnimationTree

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
const ACCEL = 0.5
var has_money = false
var is_stunned = false
var is_dead = false
var forward_vector = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	weapon = $WeaponBat
	weapon.weapon_owner = self

func _physics_process(delta):
	# Add the gravity.
	handle_gravity(delta)
	state_machine.phys_proc(delta)
	
	
	
	#handle_jump(delta)
	#handle_movement(delta)
	
	move_and_slide()

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		weapon.start_attack()
		state_machine.change_state("Swing")
		


func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta * GRAVITY_FACTOR


func handle_movement(delta, factor: float = 1.0):
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var move_dir = Input.get_axis("ui_down", "ui_up")
		var rot_dir = Input.get_axis("ui_left", "ui_right")
		var direction = Vector2.from_angle(rotation.y)
		
		velocity.x = move_toward(velocity.x, -direction.y * SPEED * move_dir, ACCEL)
		velocity.z = move_toward(velocity.z, -direction.x * SPEED * move_dir, ACCEL)
		rotation.y += -rot_dir * delta * ROTATION_SPEED
		
		velocity.x *= factor
		velocity.z *= factor
		forward_vector = velocity.dot(-transform.basis.z)
		


func handle_jump(delta):
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY


func take_damage(attack: Attack):
	if not is_dead and not is_stunned:
		if has_money:
			game_manager.drop_bag()
		health -= attack.damage
		velocity = (position - attack.knockback_source) * attack.knockback_force
		is_stunned = true
		$DamageSFX.play()
		get_tree().create_timer(attack.stun_timer).timeout.connect(func(): is_stunned = false)
		if health <= 0:
			die()


func die():
	velocity = Vector3.ZERO
	is_dead = true
	$DeathSFX.play()
	get_tree().create_timer(RESPAWN_TIMER).timeout.connect(func(): game_manager.respawn_player(self))


func stop_attack():
	weapon.stop_attack()
