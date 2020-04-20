extends KinematicBody2D

enum ENEMY_STATE { IDLE_STAND, IDLE_MOVE, SEEKING, BLOWING_CANDLE }

export var walkingSpeed = 4.0
export var directionChangeProbability = 0.8
export var maxDistanceFromStartingPosition = 50
export var currentState = ENEMY_STATE.IDLE_MOVE
export var waypoint_noise_std = 3
export var candleReachDistance = 20.0
export var candleDamage = 5.0

onready var navigation = find_parent("Navigation2D")
onready var tilemap = navigation.get_node("TileMap")
onready var sprite = $AnimatedSprite

var last_random_update_time_ms = 0
var current_direction = Vector2(0, 0)
onready var starting_position = position
var alive = true
var rng = RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_seen_candle = null

	if alive:
		if currentState == ENEMY_STATE.IDLE_MOVE:
			_on_idle_move(delta)
		elif currentState == ENEMY_STATE.SEEKING:
			_on_seeking_move(delta)
		elif currentState == ENEMY_STATE.BLOWING_CANDLE:
			_process_blowing_candle(delta)

func _ready():
	if ! OS.is_debug_build():
		$sight_area.set_visible(false)
		$waypoint_sprite.set_visible(false)
		$target_sprite.set_visible(false)
		$Line2D.set_visible(false)
		$sight_raycast.get_node("raycast viewer").set_visible(false)

var angle_rotation_progress = 0.0
var seek_target: Node2D = null

func switch_to_idle():
	seek_target = null
	currentState = ENEMY_STATE.IDLE_MOVE
	sprite.animation = 'run'

var _seen_candle: Node2D = null

func _get_seen_candle():
	if _seen_candle == null:
		var seen = $sight_area.get_overlapping_areas()
		for area in seen:
			if area.is_in_group("candle"):
				_seen_candle = area.get_parent()
				break

	return _seen_candle

func _get_candle_distance():
	var candle = _get_seen_candle()
	if candle == null:
		return INF
	return to_local(candle.global_position).length()

func _on_idle_move(delta):
	angle_rotation_progress += 2 * PI * delta * 0.3
	var angle_delta = sin(angle_rotation_progress) * PI / 3
	$sight_area.rotation = current_direction.angle() + angle_delta

	var target = _get_seen_candle()
	if target != null:
		switch_to_seeking(target)
		return

	_walk_towards(current_direction, delta)

	if _get_candle_distance() < candleReachDistance:
		switch_to_blowing_candle()


func _walk_towards(dir, deltaTime):
	var _i = move_and_slide(dir.normalized() * walkingSpeed * deltaTime * 1000.0)
	_update_animation(dir)


func switch_to_seeking(candle):
	seek_target = candle.get_node("Area2D")
	currentState = ENEMY_STATE.SEEKING
	sprite.animation = 'run'


func _find_path(global_pos: Vector2):
	# all pathfinding happens in Navigation2D's frame of reference.
	var me_world = navigation.to_local(get_global_position())
	var target_world = navigation.to_local(global_pos)
	var points = navigation.get_simple_path(me_world, target_world)

	# the returned points are in the local frame of reference
	var local_path = PoolVector2Array()
	for point in points:
		# nav wayponits are snapped to each tile's center
		var snapped_point = tilemap.map_to_world(tilemap.world_to_map(tilemap.to_local(point)))

		var waypoint_noise = Vector2(rng.randfn(0, waypoint_noise_std), rng.randfn(0, waypoint_noise_std))

		local_path.append(waypoint_noise + to_local(snapped_point * 0.5 + point * 0.5))
	return local_path


func _get_next_waypoint(seek_path: PoolVector2Array):
	if seek_path.size() < 2:
		return null
	return seek_path[1]


var target_global_pos: Vector2 = Vector2.ZERO

func look_at(target_global: Vector2):
	$sight_area.rotation = to_local(target_global).angle()
	current_direction = to_local(target_global).normalized()
	angle_rotation_progress = 0.0

func _on_seeking_move(delta):
	$sight_raycast.cast_to = $sight_raycast.to_local(seek_target.global_position)
	$sight_raycast.update()
	var collider = $sight_raycast.get_collider()
	if collider == seek_target:
		# Target visible. Seek actively.
		target_global_pos = seek_target.global_position
	else:
		# Lost sight of the target, but will still seek the point where the
		# enemy was last seen
		pass
	$target_sprite.position = to_local(target_global_pos)

	# Look where we're going (which influences what can be seen...!)
	look_at(target_global_pos)

	var seek_path = _find_path(target_global_pos)
	$Line2D.points = seek_path
	while true:
		var next_waypoint = _get_next_waypoint(seek_path)
		if next_waypoint == null:
			# Path exhausted; no where else to walk.  Lost sight of the enemy,
			# definitively.
			print('Nowhere to walk!')
			$waypoint_sprite.visible = false
			switch_to_idle()
			break
		else:
			$waypoint_sprite.visible = true
			$waypoint_sprite.position = next_waypoint

		# next_waypoint is in local coordintes => its length is the distance from the character
		if next_waypoint.length() < 3.0:
			# Waypoint reached
			seek_path.remove(0)
			continue

		_walk_towards(next_waypoint, delta)
		break

	if _get_candle_distance() < candleReachDistance:
		switch_to_blowing_candle()

func switch_to_blowing_candle():
	currentState = ENEMY_STATE.BLOWING_CANDLE
	sprite.animation = 'attacking'
	$candle_hurt_timer.start()

func _process_blowing_candle(_delta):
	var dist = _get_candle_distance()
	if dist >= candleReachDistance:
		$candle_hurt_timer.stop()
		switch_to_idle()

func _hurt_candle():
	var candle = _get_seen_candle()
	if candle == null:
		return
	# `candle` is the object on the floor, the following is *the* candle,
	# the player's soul
	var the_candle = get_tree().root.find_node("Candle", true, false)
	if the_candle == null:
		print("WTF")
	else:
		the_candle.hurt_by_enemy(candleDamage)

func _update_animation(direction):
	if direction == Vector2.ZERO:
		sprite.animation = 'idle'
	else:
		sprite.animation = 'run'
		sprite.flip_h = (direction.x < 0)


func _die():
	pass


func on_on_hole():
	if alive:
		alive = false
		var fall_animation_prefab = load("res://prefabs/FallAnimation.tscn")
		var fall_animation = fall_animation_prefab.instance()
		fall_animation.connect("fall_animation_completed", self, "_die")
		add_child(fall_animation)


func _on_change_direction_timer_timeout():
	if randf() > directionChangeProbability:
		return

	var start_pos_vector = starting_position - position
	if start_pos_vector.length() < maxDistanceFromStartingPosition:
		current_direction = _random_dir()
	else:
		current_direction = start_pos_vector.normalized()


# returns a normalized direction between ([-1, 1], [-1, 1])
func _random_dir():
	var x = rand_range(-1, 1)
	var y = rand_range(-1, 1)
	return Vector2(x, y).normalized()
