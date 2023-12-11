extends CharacterBody3D
class_name Player

@onready var game_manager: Node3D = $"../GameManager"
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var state_machine = $StateMachine as StateMachine
@onready var animation_player = $weasel/AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationTree as AnimationTree
@onready var camera_arm = $CameraArm
@onready var camera_slot =  $CameraArm/CameraSlot

var player_id = 0
var team_id
const FULL_HEALTH = 10.0
@export var health = 10.0
@export var weapon: Weapon
const RESPAWN_TIMER = 1
const SPEED = 10.0
const JUMP_VELOCITY = 15.0
const ROTATION_SPEED = 1.5
const GRAVITY_FACTOR = 4.0
const ACCEL = 0.5
var has_money = false
var is_stunned = false
var is_dead = false
var forward_vector = 0.0
var side_vector = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	weapon = $WeaponBat
	$weasel/rig/Skeleton3D/BoneAttachment3D/RemoteTransform3D.remote_path = weapon.get_path()
	weapon.weapon_owner = self


func _physics_process(delta):
	# Add the gravity.
	handle_gravity(delta)
	state_machine.phys_proc(delta)
	
	move_and_slide()

#region Handlers
func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta * GRAVITY_FACTOR

func handle_movement(_delta, factor: float = 1.0):
		var input_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var input_vec_3d = Vector3(input_vec.x, 0, input_vec.y)
		
		var basis_z_2d = Vector2(-transform.basis.z.x, -transform.basis.z.z)
		var cam_basis_z_2d = Vector2(camera_arm.transform.basis.z.x, -camera_arm.transform.basis.z.z)
		var movement_vec = input_vec_3d.rotated(transform.basis.y, basis_z_2d.angle_to(cam_basis_z_2d))
		var move_vec_2d = Vector2(movement_vec.x, movement_vec.z)
		
		# Rotate camera left or right according to player input
		camera_arm.rotate_y(-input_vec_3d.x / 30)
		
		# Rotate player so it's facing its movement vector (so it looks to where it's going)#
		rotation.y = rotate_toward(rotation.y, rotation.y + move_vec_2d.angle_to(basis_z_2d), 0.1)
		
		# Counteract player rotation so the camera is stationary
		camera_arm.rotation.y = rotate_toward(camera_arm.rotation.y, camera_arm.rotation.y-move_vec_2d.angle_to(basis_z_2d), 0.1)
		
		# Slowly pan back camera to behind the character
		#camera_arm.rotation.y = lerp_angle(camera_arm.rotation.y, 0, 0.01)
		#camera_arm.rotation.y = rotate_toward(camera_arm.rotation.y, 0, 0.01)
		
		movement_vec *= SPEED
		velocity.x = move_toward(velocity.x, movement_vec.x, ACCEL)
		velocity.z = move_toward(velocity.z, movement_vec.z, ACCEL)
		
		velocity.x *= factor
		velocity.z *= factor
		
		forward_vector = Vector2(velocity.x, velocity.z).length()
		var turning_angle = transform.basis.z.signed_angle_to(movement_vec, transform.basis.y)
		side_vector = sin(turning_angle)

func handle_jump(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		weapon.attack()
		state_machine.change_state("Attack")
#endregion

#region Combat
func take_damage(attack: Attack):
	if not is_dead and not is_stunned:
		if has_money:
			game_manager.drop_bag()
		health -= attack.damage
		velocity = (position - attack.knockback_source) * attack.knockback_force
		get_tree().create_timer(attack.stun_timer).timeout.connect(func(): state_machine.change_state("Base"))
		if health <= 0:
			die()
		state_machine.change_state("Hurt")
		#look_at(attack.knockback_source, transform.basis.y)

func die():
	velocity = Vector3.ZERO
	get_tree().create_timer(RESPAWN_TIMER).timeout.connect(func(): game_manager.respawn_player(self))
	state_machine.change_state("Dead")

func stop_attack():
	weapon.stop_attack()
#endregion
