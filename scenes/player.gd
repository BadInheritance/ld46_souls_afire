extends KinematicBody2D

export var walkingSpeed = 1.0

onready var sprite = $AnimatedSprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var deltaSecs = delta * 1000.0
	
	var dirX: float = 0
	var dirY: float = 0
	if Input.is_action_pressed("player_up"):
		dirY = -1
	if Input.is_action_pressed("player_down"):
		dirY = +1
	if Input.is_action_pressed("player_left"):
		dirX = -1
	if Input.is_action_pressed("player_right"):
		dirX = +1
	
	var dir = Vector2(dirX, dirY).normalized()
	move_and_slide(dir * walkingSpeed * deltaSecs)

	if dir == Vector2.ZERO:
		sprite.animation = 'idle'
	else:
		sprite.animation = 'run'
		sprite.flip_h = (dirX < 0)
