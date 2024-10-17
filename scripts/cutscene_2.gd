extends Node2D


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'transition':
		$AnimationPlayer.play("fade_out") 
	if anim_name == 'fade_out':
		get_tree().change_scene_to_file("res://scenes/cutscene_3.tscn")
