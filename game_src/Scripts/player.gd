extends CharacterBody2D

class_name Player

signal points_scored(points: int) 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SMALL,
	BIG,
	SHOOTING
}

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const BIG_MARIO_COLLISION_SHAPE = preload("res://Resources/CollisionShapes/big_mario_collision_shape.tres")
const SMALL_MARIO_COLLISION_SHAPE = preload("res://Resources/CollisionShapes/small_mario_collision_shape.tres")

# References
@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_2d = $Area2D
@onready var area_collision_shape = $Area2D/AreaCollisionShape 
@onready var body_collision_shape = $BodyCollisionShape

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200.0
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150
@export_group("")

var player_mode = PlayerMode.SMALL

# Player states flags
var is_dead = false


func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Handle jump height
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
		
	# Handle axis movement
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		
	animated_sprite_2d.trigger(velocity, direction, player_mode)
	
	var collision = get_last_slide_collision()
	if collision != null:
		handle_movement_collision(collision)
	
	move_and_slide()


func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)
	if area is Shroom:
		handle_shroom_collision(area)
		area.queue_free()
	if area is ShootingFlower:
		handle_flower_collision()
		area.queue_free()
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null and is_dead:
		return
		
	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		(enemy as Koopa).on_stomp(global_position)
		spawn_points_labl(enemy)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		
		if angle_of_collision > min_stomp_degree and angle_of_collision < max_stomp_degree:
			enemy.die()
			on_enemy_stomped()
			spawn_points_labl(enemy)
		else:
			die()
		

func handle_shroom_collision(area: Shroom):
	if player_mode == PlayerMode.SMALL:
		set_physics_process(false)
		animated_sprite_2d.play("small_to_big")
		set_collision_shape(false)
		
func handle_flower_collision():
	set_physics_process(false)
	var animation_name = "small_to_shooting" if player_mode == PlayerMode.SMALL else "big_to_shooting"
	animated_sprite_2d.play(animation_name)
	set_collision_shape(false)
	
	
func spawn_points_labl(enemy: Enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

func on_enemy_stomped():
	velocity.y = stomp_y_velocity

func die():
	if player_mode == PlayerMode.SMALL:
		is_dead = true
		animated_sprite_2d.play("death")

		area_2d.set_collision_mask_value(3, false)
		set_collision_layer_value(1, false)

		set_physics_process(false)
		
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self, "position", position + Vector2(0, -48), 0.5)
		death_tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1)
		death_tween.tween_callback(func (): get_tree().reload_current_scene())
	else:
		big_to_small()
	

func handle_movement_collision(collision: KinematicCollision2D):
	if collision.get_collider() is Block:
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 180:
			(collision.get_collider() as Block).bump(player_mode) 

func set_collision_shape(is_small: bool):
	var collision_shape = SMALL_MARIO_COLLISION_SHAPE if is_small else BIG_MARIO_COLLISION_SHAPE
	area_collision_shape.set_deferred("shape", collision_shape)
	body_collision_shape.set_deferred("shape", collision_shape)

func big_to_small():
	set_collision_layer_value(1, false)
	set_physics_process(false)
	var animation_name = "small_to_big" if player_mode == PlayerMode.BIG else "small_to_shooting"
	animated_sprite_2d.play(animation_name, 1.0, true)
	set_collision_shape(true)
	
