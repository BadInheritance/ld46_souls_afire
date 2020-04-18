extends KinematicBody2D

export var walkingSpeed = 5
export var runningSpeed = 15
export var rollingSpeed = 30

onready var sprite = $AnimatedSprite
onready var item_picking = $"Item picking"
onready var rolling_timer = $RollingTimer

func _process(delta):
	if Input.is_action_just_pressed("player_putdown"):
		var item = item_picking.put_down(self.position)
		if item != null:
			return
		
	if Input.is_action_just_pressed("player_action"):
		if item_picking.try_pickup():
			return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# While the rolling timer is ticking, we're rolling
	if rolling_timer.is_stopped():
		_process_walking(delta)
	else:
		_process_rolling(delta)

var rolling_dir = Vector2.ZERO

func _start_rolling(dir):
	sprite.animation = 'idle'
	sprite.playing = false
	rolling_dir = dir
	rolling_timer.start()
	
func _process_rolling(delta):
	rotate(2 * PI / rolling_timer.wait_time * delta)
	move_and_slide(rolling_dir * rollingSpeed * delta * 1000.0)
	
func _stop_rolling():
	# called when the rolling timer expires
	sprite.playing = true
	rotation = 0
	
func _process_walking(delta):
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
	if dir != Vector2.ZERO and Input.is_action_just_pressed('player_roll'):
		_start_rolling(dir)
		return
	
	var speed = walkingSpeed
	if Input.is_action_pressed("player_run"):
		speed = runningSpeed
	move_and_slide(dir * speed * deltaSecs)

	if dir == Vector2.ZERO:
		sprite.animation = 'idle'
	else:
		sprite.animation = 'run'
		sprite.flip_h = (dirX < 0)
