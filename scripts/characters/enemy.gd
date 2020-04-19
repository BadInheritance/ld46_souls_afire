extends KinematicBody2D

enum ENEMY_STATE {
    IDLE_STAND,
    IDLE_MOVE,
	SEEKING
}

export var walkingSpeed = 4.0
export var directionChangeProbability = 0.8
export var maxDistanceFromStartingPosition = 50
export var currentState = ENEMY_STATE.IDLE_MOVE
export var sightDistance = 50.0

onready var navigation = find_parent("Navigation2D")
onready var tilemap = navigation.get_node("TileMap")
onready var sprite = $AnimatedSprite

var last_random_update_time_ms = 0
var current_direction = Vector2(0, 0)
onready var starting_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if currentState == ENEMY_STATE.IDLE_MOVE:
		_on_idle_move(delta)
	elif currentState == ENEMY_STATE.SEEKING:
		_on_seeking_move(delta)
		
var angle_rotation_progress = 0.0

func _on_idle_move(delta):
	angle_rotation_progress += 2 * PI * delta
	var angle_delta = sin(angle_rotation_progress) * PI / 3
	$sight_raycast.cast_to = current_direction.rotated(angle_delta) * sightDistance
		
	var collider = $sight_raycast.get_collider()
	if collider != null:
		print('Seeing:', collider)
	if collider is Area2D and collider.is_in_group("player"):
		switch_to_seeking(collider)
		return
	
	_walk_towards(current_direction, delta)

func _walk_towards(dir, deltaTime):
	var _i = move_and_slide(dir.normalized() * walkingSpeed * deltaTime * 1000.0)
	_update_animation(dir)


var seek_target: Node2D = null

func switch_to_seeking(target):
	seek_target = target
	currentState = ENEMY_STATE.SEEKING
	
func _find_path():
	# all pathfinding happens in Navigation2D's frame of reference.
	var me_world = navigation.to_local(get_global_position())
	var target_world = navigation.to_local(seek_target.global_position)
	var points = navigation.get_simple_path(me_world, target_world)
	
	# the returned points are in the local frame of reference
	var local_path = PoolVector2Array()
	for point in points:
		# nav wayponits are snapped to each tile's center
		var snapped_point = tilemap.map_to_world(tilemap.world_to_map(tilemap.to_local(point)))
		local_path.append(to_local(snapped_point*0.5 + point*0.5))
	return local_path
		
func _get_next_waypoint(seek_path: PoolVector2Array) -> Vector2:
	if seek_path.size() < 2:
		return Vector2.ZERO
	return seek_path[1]
	
func _on_seeking_move(delta):
	var seek_path = _find_path()
	$Line2D.points = seek_path
	while true:
		var next_waypoint = _get_next_waypoint(seek_path)
		$Sprite.position = next_waypoint
		if next_waypoint == Vector2.ZERO:
			print('Nowhere to walk!')
			break 

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


var alive = true

func on_on_hole():
    if alive:
        scale = Vector2(0.1, 0.1)
        alive = false


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


