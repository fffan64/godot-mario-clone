extends Area2D

class_name Flag



func _on_body_entered(body):
	if body is Player:
		body.on_pole_hit()
