extends KinematicBody2D

export var walkingSpeed = 5
export var runningSpeed = 15
export var rollingSpeed = 30
export var wallDistance = 20

onready var sprite = $AnimatedSprite
onready var item_picking = $"Item picking"
onready var rolling_timer = $RollingTimer
onready var wallTimer = $WallTimer
onready var hor_wall_scene = preload("res://prefabs/HorizontalMagicWall.tscn")
onready var ver_wall_scene = preload("res://prefabs/VerticalMagicWall.tscn")

var alive = true
var facing_direction = "right"

signal player_die
signal player_reached_hatch
signal cast_wall_spell
signal on_candle_visible(visible)

func on_on_hatch():
	emit_signal("player_reached_hatch")

func _on_object_pick_up_update(action, object):
	print("put " + action + " object " + object.name)
	if object.name == "Lamp":
		var candle_visible = action == "up"
		emit_signal("on_candle_visible", candle_visible)

func on_on_hole():
	if alive and not is_rolling():
		scale = Vector2(0.1, 0.1)
		alive = false
		emit_signal("player_die")

func _process(_delta):
	# if Input.is_action_just_pressed("player_putdown"):
	if Input.is_action_just_pressed("player_pickup_toggle"):
		if item_picking.is_holding_something():
			var target_position = self.position
			target_position.x += 15
			var _i = item_picking.put_down(target_position)
		else:
			item_picking.try_pickup()


func is_rolling():
	return not rolling_timer.is_stopped()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# While the rolling timer is ticking, we're rolling
	if is_rolling():
		_process_rolling(delta)
	else:
		_process_walking(delta)

var rolling_dir = Vector2.ZERO


func _start_rolling(dir):
	sprite.animation = 'idle'
	sprite.playing = false
	rolling_dir = dir
	rolling_timer.start()


func _process_rolling(delta):
	rotate(2 * PI / rolling_timer.wait_time * delta)
	var _i = move_and_slide(rolling_dir * rollingSpeed * delta * 1000.0)


func _stop_rolling():
	# called when the rolling timer expires
	sprite.playing = true
	rotation = 0


func _process_walking(delta):
	var deltaSecs = delta * 1000.0

	var dirX: float = 0
	var dirY: float = 0
	if Input.is_action_pressed("player_up"):
		facing_direction = "up"
		dirY = -1
	if Input.is_action_pressed("player_down"):
		facing_direction = "down"
		dirY = +1
	if Input.is_action_pressed("player_left"):
		facing_direction = "left"
		dirX = -1
	if Input.is_action_pressed("player_right"):
		facing_direction = "right"
		dirX = +1

	var dir = Vector2(dirX, dirY).normalized()

	if wallTimer.is_stopped():
		if dir != Vector2.ZERO and Input.is_action_just_pressed('player_roll'):
			if ! item_picking.is_holding_lamp():
				_start_rolling(dir)
				return

		var speed = walkingSpeed
		if Input.is_action_pressed("player_run"):
			speed = runningSpeed
		var _i = move_and_slide(dir * speed * deltaSecs)

		if Input.is_action_pressed("player_create_wall"):
			print("create wall")
			var target_position = position
			var new_wall
			if facing_direction == "up":
				target_position.y -= wallDistance
				new_wall = hor_wall_scene.instance();
			elif facing_direction == "down":
				target_position.y += wallDistance
				new_wall = hor_wall_scene.instance();
			elif facing_direction == "left":
				target_position.x -= wallDistance
				new_wall = ver_wall_scene.instance();
			elif facing_direction == "right":
				target_position.x += wallDistance
				new_wall = ver_wall_scene.instance();
			new_wall.position = target_position
			emit_signal("cast_wall_spell")
			get_parent().add_child(new_wall);
			wallTimer.start();

	if dir == Vector2.ZERO:
		sprite.animation = 'idle'
	else:
		sprite.animation = 'run'
		sprite.flip_h = (dirX < 0)
