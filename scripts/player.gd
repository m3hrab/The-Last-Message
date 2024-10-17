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

# Reference nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

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

func perform_attack():
	# Set attack state
	is_attacking = true
	attack_timer = attack_cooldown

	# Play attack animation
	animated_sprite.play("attack")

	## Enable the attack area (collision detection)
	#attack_area.monitoring = true
	#attack_area.monitorable = true
	
	var overlapping_objects = $AttackArea.get_overlapping_areas()
	for area in overlapping_objects:
		var parent = area.get_parent()
		print(parent.name)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("enemies"):
		body.take_damage(1)  # Call a method on the enemy to deal damage


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack1":
		attack_area.monitoring = false  # Disable the hit detection after attack finishes
		attack_area.monitorable = false
		print("Worked")
