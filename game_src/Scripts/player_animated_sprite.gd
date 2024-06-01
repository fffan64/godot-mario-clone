extends AnimatedSprite2D

class_name PlayerAnimatedSprite

func trigger(velocity: Vector2, direction: int, player_mode: Player.PlayerMode):
	var animation_prefix = Player.PlayerMode.keys()[player_mode].to_snake_case()
	
	if not get_parent().is_on_floor():
		play("%s_jump" % animation_prefix)
	# Handle slide animations
	elif sign(velocity.x) != sign(direction) and velocity.x != 0 and direction != 0:
		play("%s_slide" % animation_prefix)
		scale.x = direction
	else:
		# Handle the sprite direction
		if scale.x == 1 and sign(velocity.x) == -1:
			scale.x = -1
		elif scale.x == -1 and sign(velocity.x) == 1:
			scale.x = 1
			
		# Handle run and idle animations
		if velocity.x != 0:
			play("%s_run" % animation_prefix)
		else:
			play("%s_idle" % animation_prefix)
