extends KinematicBody2D

export var walkingSpeed = 5
export var runningSpeed = 15
export var sneakSpeed = 1
export var rollingSpeed = 30
export var wallDistance = 20
export var normalPlayerVolumeDb = -20
export var sneakingPlayerVolumeDb = -25
export var walkingStepInterval = 0.6
export var runningStepInterval = 0.3

onready var sprite = $PlayerSprite
onready var item_picking = $"Item picking"
onready var rolling_timer = $RollingTimer
onready var wallTimer = $WallTimer
onready var soundTimer = $PlayerSounds/SoundTimer
onready var walkingSound = $PlayerSounds/Footstep
onready var walkingTimer = 1.0 / walkingSpeed
onready var runningSound = $PlayerSounds/Footstep
onready var runningTimer = 1.0 / runningSpeed
onready var sneakingSound = $PlayerSounds/Sneak
onready var sneakingTimer = 1 / sneakSpeed
onready var rollSound = $PlayerSounds/Roll
onready var activeSoundTimer = walkingTimer
onready var activeSound = walkingSound
onready var hor_wall_scene = preload("res://prefabs/HorizontalMagicWall.tscn")
onready var ver_wall_scene = preload("res://prefabs/VerticalMagicWall.tscn")

var alive = true
var facing_direction = "right"

signal player_die
signal player_reached_hatch(with_lamp)
signal cast_wall_spell
signal activate_fountain
signal on_candle_visible(visible)


func _ready():
	walkingSound.volume_db = normalPlayerVolumeDb
	runningSound.volume_db = normalPlayerVolumeDb
	sneakingSound.volume_db = sneakingPlayerVolumeDb
	rollSound.volume_db = normalPlayerVolumeDb
	


func on_on_hatch():
	emit_signal("player_reached_hatch", item_picking.is_holding_lamp())


func _on_object_pick_up_update(action, object):
	print("put " + action + " object " + object.name)
	if object.name == "Lamp":
		var candle_visible = action == "up"
		emit_signal("on_candle_visible", candle_visible)


func _die():
	emit_signal("player_die")


func start_fall_animation():
	var fall_animation_prefab = load("res://prefabs/FallAnimation.tscn")
	var fall_animation = fall_animation_prefab.instance()
	fall_animation.connect("fall_animation_completed", self, "_die")
	add_child(fall_animation)


func on_on_hole():
	if alive and not is_rolling():
		alive = false
		start_fall_animation()


func on_fountain_activation():
	if item_picking.is_holding_lamp():
		$FountainActivator/FountainDrop1.play()
		yield($FountainActivator/FountainDrop1, "finished") 
		$FountainActivator/FountainDrop2.play()
		emit_signal("activate_fountain")


func process_debug():
	if Input.is_action_just_pressed("debug_kill_player"):
		alive = false
		start_fall_animation()


func _process(_delta):
	process_debug()
	if Input.is_action_just_pressed("player_pickup_toggle"):
		if item_picking.is_holding_something():
			var target_position = self.position
			target_position.x += 15
			var _i = item_picking.put_down(target_position)
		else:
			item_picking.try_pickup()


func is_rolling():
	return not rolling_timer.is_stopped()


func _physics_process(delta):
	if alive:
		if is_rolling():
			_process_rolling(delta)
		else:
			_process_walking(delta)


var rolling_dir = Vector2.ZERO


func _start_rolling(dir):
	sprite.animation = 'idle'
	sprite.playing = false
	rolling_dir = dir
	activeSound.stop()
	rollSound.play()
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
		activeSoundTimer = walkingTimer
		activeSound = walkingSound
		if Input.is_action_pressed("player_run"):
			speed = runningSpeed
			activeSoundTimer = runningTimer
			activeSound = runningSound

		if Input.is_action_pressed("player_sneak"):
			speed = sneakSpeed
			activeSoundTimer = sneakingTimer
			activeSound = sneakingSound

		var _i = move_and_slide(dir * speed * deltaSecs)

		if Input.is_action_pressed("player_create_wall") && item_picking.is_holding_lamp():
			print("create wall")
			var target_position = position
			var new_wall
			if facing_direction == "up":
				target_position.y -= wallDistance
				new_wall = hor_wall_scene.instance()
			elif facing_direction == "down":
				target_position.y += wallDistance
				new_wall = hor_wall_scene.instance()
			elif facing_direction == "left":
				target_position.x -= wallDistance
				new_wall = ver_wall_scene.instance()
			elif facing_direction == "right":
				target_position.x += wallDistance
				new_wall = ver_wall_scene.instance()
			new_wall.position = target_position
			emit_signal("cast_wall_spell")
			get_parent().add_child(new_wall)
			wallTimer.start()

	if dir == Vector2.ZERO:
		sprite.animation = 'idle'
		$steps_timer.stop()
	else:
		sprite.animation = 'run'
		sprite.flip_h = (dirX < 0)
		if soundTimer.is_stopped():
			activeSound.play()
			soundTimer.start(activeSoundTimer)
		if Input.is_action_pressed("player_run"):
			$steps_timer.wait_time = runningStepInterval
		else:
			$steps_timer.wait_time = walkingStepInterval
		if $steps_timer.is_stopped():
			$steps_timer.start()


func generate_step_sound():
	var scene = preload("res://prefabs/step_sound.tscn")
	var node = scene.instance()
	node.global_position = self.global_position
	node.emitter = self
	get_parent().add_child(node)
