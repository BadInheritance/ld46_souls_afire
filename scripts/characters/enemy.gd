extends KinematicBody2D

enum ENEMY_STATE { IDLE_STAND, IDLE_MOVE, SEEKING }

export var walkingSpeed = 4.0
export var directionChangeProbability = 0.8
export var maxDistanceFromStartingPosition = 50
export var currentState = ENEMY_STATE.IDLE_MOVE
export var waypoint_noise_std = 3

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
	if alive:
		if currentState == ENEMY_STATE.IDLE_MOVE:
			_on_idle_move(delta)
		elif currentState == ENEMY_STATE.SEEKING:
			_on_seeking_move(delta)


var angle_rotation_progress = 0.0

var seek_target: Node2D = null


func switch_to_idle():
	seek_target = null
	currentState = ENEMY_STATE.IDLE_MOVE

func _get_seen_candle():
	var seen = $sight_area.get_overlapping_areas()
	for area in seen:
		if area.is_in_group("candle"):
			return area
	
func _on_idle_move(delta):
	angle_rotation_progress += 2 * PI * delta * 0.3
	var angle_delta = sin(angle_rotation_progress) * PI / 3
	$sight_area.rotation = current_direction.angle() + angle_delta
	
	var target = _get_seen_candle()
	if target != null:
		switch_to_seeking(target)
		return
	
	_walk_towards(current_direction, delta)


func _walk_towards(dir, deltaTime):
	var _i = move_and_slide(dir.normalized() * walkingSpeed * deltaTime * 1000.0)
	_update_animation(dir)


func switch_to_seeking(target):
	seek_target = target
	currentState = ENEMY_STATE.SEEKING


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
	$sight_area.rotation = to_local(target_global_pos).angle()
	
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
