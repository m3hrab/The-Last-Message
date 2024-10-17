extends Node2D  # Your enemy's base class

# Enemy variables
var health = 1
var is_dead = false
var is_hurt = false
var is_attacking = false  # Track if the enemy is attacking
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_parent().get_node("Player")  # Replace with actual player path

# Movement variables
var speed = 100  # Adjust the walking speed of the enemy
var run_speed = 200  # Speed when running toward the player
var direction = Vector2(1, 0)  # Initially move right
var walk_distance = 300  # Distance to patrol before turning around
var distance_traveled = 0  # Track how far the enemy has moved

# Attack variables
var attack_distance = 150  # Distance within which the enemy can attack the player
var attack_cooldown = 2.0  # Time between attacks
var can_attack = true  # Track if the enemy can attack (based on cooldown)

# Function to handle taking damage
func take_damage():
	if is_dead or is_hurt or is_attacking:
		return  # No further damage or hurt animation if already dead, hurt, or attacking
	
	health -= 1
	if health > 0:
		is_hurt = true  # Enter hurt state
		sprite.play("hurt")
		await get_tree().create_timer(0.5).timeout  # Time for the hurt animation
		sprite.play("idle")
		await get_tree().create_timer(1.0).timeout  # Stay idle for 1 second
		sprite.play("walk")  # Resume walking animation
		is_hurt = false  # Exit hurt state and allow movement
	else:
		die()  # If health is 0 or less, trigger death

# Function to handle enemy death
func die():
	if is_dead:
		return  # If the enemy is already dead, don't die again
	
	is_dead = true
	sprite.play("dead")  # Play the 'dead' animation
	$Area2D/CollisionShape2D.disabled = true  # Disable the enemy's collision
	await get_tree().create_timer(1.0).timeout  # Wait for the dead animation to complete
	queue_free()  # Remove the enemy from the scene

# Function to flip direction and reset distance
func flip_direction():
	distance_traveled = 0  # Reset distance traveled
	direction.x *= -1  # Reverse the horizontal direction
	sprite.flip_h = direction.x < 0  # Flip the sprite based on direction

# Function to check if player is within attack distance and in front of the enemy
func is_player_in_range():
	var player_position = player.position
	var enemy_position = position
	
	# Calculate distance to player
	var distance_to_player = enemy_position.distance_to(player_position)
	
	# Check if the player is within attack distance and in front of the enemy
	var is_facing_player = (direction.x > 0 and player_position.x > enemy_position.x) or (direction.x < 0 and player_position.x < enemy_position.x)
	
	return distance_to_player <= attack_distance and is_facing_player

# Function to check if the enemy should run toward the player
func is_player_in_walk_distance():
	var player_position = player.position
	var enemy_position = position
	var distance_to_player = enemy_position.distance_to(player_position)
	
	# Enemy will run if the player is within this distance but not close enough to attack
	return distance_to_player > attack_distance and distance_to_player <= walk_distance

# Run towards the player if not close enough to attack (horizontal movement only)
func run_toward_player(delta):
	var player_position = player.position
	var move_direction = (Vector2(player_position.x, position.y) - position).normalized()  # Move only in the x-axis

	position += move_direction * run_speed * delta  # Move enemy towards the player
	sprite.flip_h = move_direction.x < 0  # Flip sprite based on direction

	# Play the run animation
	if sprite.animation != "run":
		sprite.play("run")


# Function to check if the enemy is close enough to collide with the player
func is_colliding_with_player():
	var enemy_collision_area = $Area2D  # The enemy's Area2D node
	var overlapping_areas = enemy_collision_area.get_overlapping_bodies()  # Get overlapping bodies (player)

	# Check if player is within the overlapping bodies
	for body in overlapping_areas:
		if body == player:
			return true
	return false
	
# Attack function
func attack():
	if is_dead or is_hurt:
		return  # Can't attack if dead or hurt

	if is_colliding_with_player():  # Ensure the enemy collides with the player
		is_attacking = true
		sprite.play("attack")  # Play attack animation
		await get_tree().create_timer(0.5).timeout  # Wait for the attack animation duration

		# Call the player's take_damage function
		player.take_damage()  # This will handle the player's health and death animation

		# After the attack, wait for cooldown before next attack
		await get_tree().create_timer(attack_cooldown).timeout
		is_attacking = false  # Attack is done
		sprite.play("walk")  # Resume walking or running
	else:
		# If not close enough, keep running toward the player
		run_toward_player(get_process_delta_time())  # Continue moving closer to player if not colliding

# Movement and attack logic
func _physics_process(delta):
	if is_dead or is_hurt or is_attacking:
		return  # Don't move if the enemy is dead, hurt, or attacking

	# If player is within attack distance and in front, trigger attack
	if is_player_in_range() and can_attack:
		attack()
		return  # Skip movement to focus on attack
	
	# If the player is within walking distance but not close enough to attack, run towards the player
	if is_player_in_walk_distance():
		run_toward_player(delta)
		return  # Skip patrol and move toward the player
	
	# Calculate the movement vector if not attacking or running
	var movement = direction * speed * delta
	position += movement  # Move the enemy
	distance_traveled += movement.length()  # Track how far the enemy has moved

	# If the enemy has walked the full distance, flip direction
	if distance_traveled >= walk_distance:
		flip_direction()

	# Ensure the walk animation is playing
	if sprite.animation != "walk":
		sprite.play("walk")
