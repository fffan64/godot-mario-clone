extends Area2D

class_name FallDownArea



func _on_body_entered(body):
	if body is Player:
		await get_tree().create_timer(2).timeout
		SceneData.player_mode = Player.PlayerMode.SMALL
		get_tree().reload_current_scene()
