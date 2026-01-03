extends CharacterBody2D
var input_direction = Vector2.ZERO
# Free Movement
@export var free_movement_speed : float = 80.0
@export var acceleration : float = 20
@export var sprint_speed : float = 2
# Grid Movement
var grid_position : Vector2i = Vector2i.ZERO
@export var grid_movement_speed : float = 10.0
var is_moving = false
var percentage_moved = 0.0
var initial_position = Vector2.ZERO

func _ready():
	Global.register_player(self)

func _physics_process(_delta):
	
	if Global.player_movement_type == Global.MovementTypes.FREE:
		free_movement()
	elif Global.player_movement_type == Global.MovementTypes.GRID:
		grid_movement(_delta)

func free_movement():
	input_direction = Input.get_vector("left", "right", "up", "down")
	print(input_direction)
	
	if Input.is_action_pressed("sprint"):
		input_direction *= sprint_speed
	
	animate_player(input_direction)
	
	velocity.x = move_toward(velocity.x, free_movement_speed*input_direction.x, acceleration)
	velocity.y = move_toward(velocity.y, free_movement_speed*input_direction.y, acceleration)

	move_and_slide()

func grid_movement(delta):
	
	if !is_moving:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		move(delta)
	else:
		is_moving = false
	animate_player(input_direction)

func process_player_input():
	
	input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		input_direction += Vector2.LEFT
	if Input.is_action_pressed("right"):
		input_direction += Vector2.RIGHT
	if Input.is_action_pressed("up"):
		input_direction += Vector2.UP
	if Input.is_action_pressed("down"):
		input_direction += Vector2.DOWN
	
	if input_direction != Vector2.ZERO && Global.current_scene.is_position_free(grid_position + Vector2i(input_direction)):
		initial_position = position
		is_moving = true
		grid_position += Vector2i(input_direction)
		Global.current_scene.make_turn()
	else:
		input_direction = Vector2.ZERO

func move(delta):
	var speed = grid_movement_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_speed
	
	percentage_moved += speed * delta
	if percentage_moved >= 1.0:
		position = initial_position + (16 * input_direction)
		percentage_moved = 0.0
		is_moving = false
		Global.current_scene.end_turn()
	else:
		position = initial_position + (16 * input_direction * percentage_moved)

func reset_grid_movement():
	is_moving = false
	percentage_moved = 0.0

func animate_player(movement):
	if movement.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif movement.x < 0:
		$AnimatedSprite2D.play("walk_left")
	
	if movement.y > 0:
		$AnimatedSprite2D.play("walk_down")
	elif movement.y < 0:
		$AnimatedSprite2D.play("walk_up")

	if Vector2(movement) == Vector2.ZERO:
		if $AnimatedSprite2D.animation == "walk_left":
			$AnimatedSprite2D.play("idle_left")
		elif $AnimatedSprite2D.animation == "walk_right":
			$AnimatedSprite2D.play("idle_right")
		elif $AnimatedSprite2D.animation == "walk_up":
			$AnimatedSprite2D.play("idle_up")
		elif $AnimatedSprite2D.animation == "walk_down":
			$AnimatedSprite2D.play("idle_down")

func set_player_position(pos : Vector2i):
	$CollisionShape2D.disabled = true
	reset_grid_movement()
	position = pos
	$CollisionShape2D.disabled = false

func set_player_grid_position(pos):
	grid_position = pos

func get_player_grid_position():
	return grid_position

func show_darkness():
	$DarknessSprite.show()
	
func hide_darkness():
	$DarknessSprite.hide()
