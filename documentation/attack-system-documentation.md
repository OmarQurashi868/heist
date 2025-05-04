# Attack System Documentation

## Overview

The Attack system handles damage, knockback, and stun mechanics in the Heist game. It defines how players interact in combat situations, allowing them to damage other players, steal the money bag, and temporarily disable opponents.

## Core Attack Class

The `Attack` class (`scripts/attack.gd`) is a fundamental structure that represents an attack's properties. Each weapon in the game creates and configures instances of this class.

### Properties

```gdscript
var damage: float         # Amount of health reduced from target
var stun_timer: float     # Duration target is stunned after hit
var knockback_force: float # Force applied to push target away
var knockback_source: Vector3 # Origin point of knockback direction
```

### Constructor

```gdscript
func _init(given_damage = 0, given_stun_timer = 0.5, given_knockback_force = 0, given_knockback_source = Vector3.ZERO):
    damage = given_damage
    stun_timer = given_stun_timer
    knockback_force = given_knockback_force
    knockback_source = given_knockback_source
```

## Attack Data Storage

Attacks are defined and stored in `resources/weapon_data.gd`, which contains a dictionary of predefined attacks for each weapon type:

```gdscript
var attacks = {
    "bat": Attack.new(2, 0.5, 1, Vector3.ZERO),
    "sword": Attack.new(5, 0.9, 10, Vector3.ZERO),
    "pistol": Attack.new(1, 0.1, 0, Vector3.ZERO)
}
```

Each entry specifies:
1. Damage amount
2. Stun duration
3. Knockback force
4. Default knockback source (updated at runtime with attacker's position)

## Attack Processing Flow

1. **Weapon Initiates Attack**: When a player triggers an attack, the weapon's `attack()` method is called.

2. **Attack Properties Set**: 
   ```gdscript
   func start_attack():
       weapon_attack.knockback_source = weapon_owner.global_position
       if $AttackSFX:
           $AttackSFX.play()
       start_cooldown()
   ```

3. **Contact Detection**:
   - For melee weapons: Area3D collision with player bodies
   - For hitscan weapons: Raycast detection

4. **Damage Application**: When a valid target is hit, `try_deal_damage()` is called:
   ```gdscript
   func try_deal_damage(target: Player):
       if target and target.has_method("take_damage") and weapon_owner and target != weapon_owner:
           target.take_damage(weapon_attack)
   ```

5. **Target Receives Damage**: The target's `take_damage()` method processes the attack:
   ```gdscript
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
   ```

## Integration with State Machine

The attack system interacts closely with the State Machine system:

1. **Attack State**: When attacking, players enter the `Attack` state
2. **Hurt State**: When damaged, players enter the `Hurt` state
3. **Dead State**: When health reaches zero, players enter the `Dead` state

## Attack Animation

Attacks are visualized through the AnimationTree:
```gdscript
func on_enter():
    player.animation_tree.set("parameters/weapon_anim/transition_request", player.weapon.animation_name)
    player.animation_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE) 
```

## Cooldown System

Weapons enforce cooldown periods between attacks:
```gdscript
func start_cooldown():
    can_attack = false
    get_tree().create_timer(cooldown_duration).timeout.connect(func(): can_attack = true)
```

## Key Interactions with Other Systems

- **Money Bag**: Attacking a player carrying the money bag causes them to drop it
- **Player Movement**: During attacks, movement may be restricted based on the weapon's `can_attack_move` and `weight` properties
- **Health System**: Attacks reduce player health, potentially causing death
- **State Machine**: Attacks trigger state changes for both attacker and target
- **Game Manager**: Notified when a money bag carrier is attacked

## Extending the Attack System

To add new attack types:

1. Add a new entry to the `attacks` dictionary in `resources/weapon_data.gd`
2. Create appropriate animations for the attack
3. Configure the weapon to use the new attack

To modify attack behavior:

1. Adjust damage, stun timer, and knockback values
2. Consider adding status effects or special properties (would require extending the `Attack` class)
