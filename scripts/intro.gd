extends Node2D
var can_click = false

func _process(delta: float) -> void:
	$Camera2D.position.x += delta * 50


func _on_button_pressed() -> void:
	if can_click:
		$AnimationPlayer.play("fade_out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'fade_out':
		get_tree().change_scene_to_file("res://scenes/cutscene1.tscn")


func _on_timer_timeout() -> void:
	can_click = true


func _on_button_2_pressed() -> void:
	pass # Replace with function body.
