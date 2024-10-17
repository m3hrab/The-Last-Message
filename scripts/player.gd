extends CharacterBody2D

# Speed variables
var walk_speed = 100
var run_speed = 200
var jump_force = -400
var gravity = 800

# Attack variables
var is_attacking = false
var attack_cooldown = 0.5  # Attack cooldown in seconds
var attack_timer = 0.0
var is_not_dead = true
# Reference nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

var health = 1
		
func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	# Attack handling
	if attack_timer > 0:
		attack_timer -= delta
	else:
		is_attacking = false
	
	if Input.is_action_just_pressed("attack1") and not is_attacking:
		perform_attack()

	# Movement handling (only if not attacking)
	if not is_attacking:
		handle_movement(delta)

	# Move the character
	move_and_slide()

func handle_movement(delta):
	var direction = Vector2.ZERO
	var current_speed = walk_speed

	if Input.is_action_pressed("right"):
		direction.x += 1
	elif Input.is_action_pressed("left"):
		direction.x -= 1

	# Shift key for running
	if Input.is_action_pressed("speed_up"):
		current_speed = run_speed

	# Apply movement direction
	velocity.x = direction.x * current_speed

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	# Flip the sprite based on direction
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

	#if velocity.x != 0:
		#animated_sprite.flip_h = velocity.x < 0
#
		## Flip the attack area position based on the direction
		#if velocity.x < 0:
			#attack_area.position.x = -abs(attack_area.position.x)  # Move to the left
		#else:
			#attack_area.position.x = abs(attack_area.position.x) 

	if is_not_dead:
		# Play appropriate animations
		if not is_on_floor():
			animated_sprite.play("jump")
			
		elif velocity.x != 0:
			# Play "run" if running, otherwise "walk"
			if current_speed == run_speed:
				animated_sprite.play("run")
			else:
				animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("dead")
		await get_tree().create_timer(.5).timeout
		get_tree().reload_current_scene()
		

func perform_attack():
	
	var overlapping_objects = $AttackArea.get_overlapping_areas()
	for area in overlapping_objects:
		var parentNode = area.get_parent()
		parentNode.take_damage()
	# Set attack state
	is_attacking = true
	attack_timer = attack_cooldown

	# Play attack animation
	animated_sprite.play("attack")
 

func _on_kill_zone_dead() -> void:
	print("Called on Player")
	#is_not_dead = false
	
# Player script

# Function to handle taking damage
func take_damage():
	health -= 1  # Assuming health is a variable tracking player health
	if health <= 0:
		die()  # Call the die function if health is 0 or less

# Function to play the player's death animation
func die():
	animated_sprite.play("dead")  # Assuming you have a sprite variable for player's AnimatedSprite2D
	await get_tree().create_timer(.5).timeout
	get_tree().reload_current_scene()
