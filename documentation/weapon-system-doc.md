# Weapon System Documentation

## Overview

The Weapon System provides the combat functionality for the Heist game. It uses inheritance to create different weapon types with shared base functionality. Weapons affect player movement, can deal damage to other players, and have various properties like cooldown and animations.

## File Structure

- `scripts/weapon.gd`: Base weapon class
- `scripts/weapon_melee.gd`: Melee weapon implementation
- `scripts/weapon_hitscan.gd`: Ranged weapon implementation
- `scripts/attack.gd`: Attack data class
- `resources/weapon_data.gd`: Stores weapon statistics

## Core Classes

### Weapon Base Class

The `Weapon` class (`scripts/weapon.gd`) serves as the foundation for all weapons:

```gdscript
extends Node3D
class_name Weapon

@export var weapon_name: String       # Identifier for the weapon
@export var weapon_tier: int          # Tier/level of weapon
@export var cooldown_duration: float  # Time between attacks
@export var weight: float = 0         # Affects player movement speed
@export var can_attack_move: bool = false  # Whether player can move while attacking
@export var animation_name: String    # Name of animation in AnimationTree
@export var equipped = true           # Whether weapon is currently equipped

@onready var hitbox: Area3D           # Area for damage detection (set by subclasses)
var weapon_owner: Player              # Who wields this weapon
var weapon_attack: Attack = Attack.new()  # Attack data
var weapon_data: WeaponData = preload("res://resources/weapon_data.tres")  # Weapon stats
var can_attack = true                 # Whether weapon can attack (cooldown)
```

Key methods:
```gdscript
func _ready():
    weapon_attack = weapon_data.attacks[weapon_name]

# Called when player attacks - implemented by subclasses
func attack():
    pass

# Common damage logic
func try_deal_damage(target: Player):
    if target\
    and target.has_method("take_damage")\
    and weapon_owner\
    and target != weapon_owner:
        target.take_damage(weapon_attack)

# Common attack start logic
func start_attack():
    weapon_attack.knockback_source = weapon_owner.global_position
    if $AttackSFX:
        $AttackSFX.play()
    start_cooldown()

# Start attack cooldown
func start_cooldown():
    can_attack = false
    get_tree().create_timer(cooldown_duration).timeout.connect(func(): can_attack = true)

# Called when attack ends - implemented by subclasses
func stop_attack():
    pass
```

### Melee Weapon Class

The `WeaponMelee` class (`scripts/weapon_melee.gd`) implements close-range weapons:

```gdscript
extends Weapon
class_name WeaponMelee

func _ready():
    super()
    hitbox = $Area3D as Area3D
    hitbox.body_entered.connect(hitbox_touched)
    hitbox.monitoring = false

# Override attack method
func attack():
    if equipped and can_attack:
        start_attack()

# Override start_attack to enable hitbox
func start_attack():
    super()
    hitbox.monitoring = true

# Override stop_attack to disable hitbox
func stop_attack():
    hitbox.monitoring = false

# Handle hits
func hitbox_touched(body):
    if body.is_in_group("player"):
        try_deal_damage(body)
```

### Hitscan Weapon Class

The `WeaponHitscan` class (`scripts/weapon_hitscan.gd`) implements instant-hit ranged weapons:

```gdscript
extends Weapon
class_name WeaponHitscan

@export var ammo = 10

# Override attack method
func attack():
    if equipped and can_attack and ammo > 0:
        shoot_weapon()

# Implement shooting logic
func shoot_weapon():
    start_attack()
    var shooting_target = owner.get_node("AimRay").get_collider()
    $MuzzleFlash.emitting = true
    if shooting_target and shooting_target.is_in_group("player"):
        try_deal_damage(shooting_target)
```

### Attack Class

The `Attack` class (`scripts/attack.gd`) stores attack properties:

```gdscript
extends Node
class_name Attack

var damage: float           # Amount of health to remove
var stun_timer: float       # How long target is stunned
var knockback_force: float  # Knockback strength
var knockback_source: Vector3  # Origin point of knockback

func _init(given_damage = 0, given_stun_timer = 0.5, given_knockback_force = 0, given_knockback_source = Vector3.ZERO):
    damage = given_damage
    stun_timer = given_stun_timer
    knockback_force = given_knockback_force
    knockback_source = given_knockback_source
```

### Weapon Data Resource

The `WeaponData` class (`resources/weapon_data.gd`) stores weapon statistics:

```gdscript
extends Resource
class_name WeaponData

var attacks = {
    "bat": Attack.new(2, 0.5, 1, Vector3.ZERO),
    "sword": Attack.new(5, 0.9, 10, Vector3.ZERO),
    "pistol": Attack.new(1, 0.1, 0, Vector3.ZERO)
}
```

## Weapon Lifecycle

1. **Initialization**:
   - Weapon is created as part of player scene or added dynamically
   - Player script connects to weapon via `$WeaponBat`
   - Weapon gets owner reference: `weapon_owner = self`
   - Weapon loads attack data from WeaponData resource

2. **Attack Process**:
   - Player calls `weapon.attack()` when attack button is pressed
   - Weapon checks if it can attack (cooldown, equipped)
   - Weapon performs attack logic (melee activates hitbox, hitscan traces ray)
   - On hit, weapon calls `try_deal_damage()` which calls `target.take_damage()`
   - Weapon starts cooldown timer

3. **Attack End**:
   - For melee weapons, hitbox is disabled in `stop_attack()`
   - Player state machine transitions from Attack back to Base

## Weapon Attachment System

Weapons are attached to the player character's skeleton using a `RemoteTransform3D`:

```gdscript
# In Player.gd
func _ready():
    weapon = $WeaponBat
    $weasel/rig/Skeleton3D/BoneAttachment3D/RemoteTransform3D.remote_path = weapon.get_path()
    weapon.weapon_owner = self
```

This setup ensures the weapon follows the correct bone during animations.

## Integration with Player System

The weapon system affects player behavior in several ways:

1. **Movement Speed**: Weapons have a `weight` property that reduces player speed
   ```gdscript
   # In player states
   player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
   ```

2. **Attack State**: When player attacks, it transitions to the Attack state
   ```gdscript
   # In Base.gd
   func handle_attack():
       if Input.is_action_just_pressed("attack"):
           weapon.attack()
           state_machine.change_state("Attack")
   ```

3. **Attack Mobility**: Some weapons allow movement during attacks
   ```gdscript
   # In Attack.gd
   func phys_proc(delta):
       if player.weapon.can_attack_move:
           player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
       else:
           player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)
   ```

## Weapon Animations

Weapons use the player's AnimationTree for animations:

```gdscript
# In Attack.gd
func on_enter():
    player.animation_tree.set("parameters/weapon_anim/transition_request", player.weapon.animation_name)
    player.animation_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
```

The `animation_name` property of each weapon must match a state in the AnimationTree's state machine.

## Adding New Weapons

To add a new weapon:

1. **Create a Scene**:
   - Create a new scene inheriting from an existing weapon type
   - Add 3D model, collision shapes, and required nodes

2. **Configure Properties**:
   - Set exported properties like `weapon_name`, `cooldown_duration`, etc.
   - Set `animation_name` to match an animation in the player's AnimationTree

3. **Update Weapon Data**:
   - Add new weapon to `resources/weapon_data.gd`
   ```gdscript
   var attacks = {
       "bat": Attack.new(2, 0.5, 1, Vector3.ZERO),
       "sword": Attack.new(5, 0.9, 10, Vector3.ZERO),
       "pistol": Attack.new(1, 0.1, 0, Vector3.ZERO),
       "new_weapon": Attack.new(3, 0.7, 5, Vector3.ZERO)  # Add new weapon here
   }
   ```

4. **Add Animations**:
   - Create attack animation in the player's AnimationPlayer
   - Connect it to the AnimationTree

### Example: Creating a "Hammer" Weapon

```gdscript
# hammer.gd
extends WeaponMelee

func _ready():
    super()
    weapon_name = "hammer"
    cooldown_duration = 1.2
    weight = 3.0
    can_attack_move = false
    a