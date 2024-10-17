extends CharacterBody2D

var health = 3

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()  # Removes the enemy from the scene
