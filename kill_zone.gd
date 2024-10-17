extends Area2D
signal dead

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()



func _on_body_entered(body: Node2D) -> void:
	$Timer.start()
	dead.emit()
