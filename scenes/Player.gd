extends CharacterBody3D


const SPEED = 8.0
const JUMP_VELOCITY = 15.0
const ROTATION_SPEED = 1.5
const GRAVITY_FACTOR = 4.0
var player_id = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * GRAVITY_FACTOR

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_dir = Input.get_axis("ui_down", "ui_up")
	var rot_dir = Input.get_axis("ui_left", "ui_right")
	
	var direction = Vector2.from_angle(rotation.y)
	velocity.x = move_toward(velocity.x, -direction.y * SPEED * move_dir, SPEED)
	velocity.z = move_toward(velocity.z, -direction.x * SPEED * move_dir, SPEED)
	rotation.y += -rot_dir * delta * ROTATION_SPEED
	
	move_and_slide()
