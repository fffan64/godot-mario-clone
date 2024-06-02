extends Area2D

class_name Flag

@onready var flag_sprite = $FlagSprite as Sprite2D
@onready var animation_player = $AnimationPlayer

var finished = false

func _on_body_entered(body):
	if body is Player:
		if !finished:
			finished = true
			body.on_pole_hit()
			animation_player.play("flag_down")
