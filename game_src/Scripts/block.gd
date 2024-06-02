extends StaticBody2D

class_name Block

@onready var ray_cast_2d = $RayCast2D as RayCast2D

func bump(player_mode: Player.PlayerMode):
	var bump_tween = get_tree().create_tween()
	bump_tween.tween_property(self, "position", position + Vector2(0, -5), .12)
	bump_tween.chain().tween_property(self, "position", position, .12)
	check_for_enemy_collision()
	check_for_shroom_collision()

func check_for_enemy_collision():
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() is Enemy:
		var enemy = ray_cast_2d.get_collider() as Enemy
		enemy.die_from_hit()

func check_for_shroom_collision():
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() is Shroom:
		var shroom = ray_cast_2d.get_collider() as Shroom
		shroom.horizontal_speed *= -1

		shroom.set_process(false)
		var bump_tween = get_tree().create_tween()
		bump_tween.tween_property(shroom, "position", shroom.position + Vector2(0, -5), .12)
		bump_tween.chain().tween_property(shroom, "position", position, .12)
		bump_tween.tween_callback(func (): shroom.set_process(true))
