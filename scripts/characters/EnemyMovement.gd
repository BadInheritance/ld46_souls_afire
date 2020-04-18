extends KinematicBody2D

enum ENEMY_STATE {
	IDLE_STAND,
	IDLE_MOVE,
}

export var walkingSpeed = 4.0
export var directionChangeProbability = 0.8
export var maxDistanceFromStartingPosition = 50
export var currentState = ENEMY_STATE.IDLE_MOVE

onready var sprite = $AnimatedSprite

var last_random_update_time_ms = 0
var current_direction = Vector2(0, 0)
var starting_position = Vector2(0, 0)


func _get_current_time():
	return OS.get_ticks_msec()


func _should_dir_change(current_time_ms):
	var delta_t = current_time_ms - last_random_update_time_ms
	var DIRECTION_CHANGE_EVENT_MS = 1000
	if delta_t > DIRECTION_CHANGE_EVENT_MS:
		last_random_update_time_ms = current_time_ms
		return randf() < directionChangeProbability
	return false


func _vector_to_starting_position():
	return starting_position - position


# returns a normalized direction between ([-1, 1], [-1, 1]) 
func _random_dir():
	var x = rand_range(-1, 1)
	var y = rand_range(-1, 1)
	return Vector2(x, y).normalized()


func _update_animation(direction):
	if direction == Vector2.ZERO:
		sprite.animation = 'idle'
	else:
		sprite.animation = 'idle'
		sprite.flip_h = (direction.x < 0)


func _update_direction():
	var current_time_ms = _get_current_time()
	if _should_dir_change(current_time_ms):
		var start_pos_vector = _vector_to_starting_position()
		if start_pos_vector.length() < maxDistanceFromStartingPosition:
			current_direction = _random_dir().normalized()
		else:
			current_direction = start_pos_vector.normalized()


func _init():
	starting_position = position


func _on_idle_move(delta):
	var deltaSecs = delta * 1000.0
	_update_direction()
	var _i = move_and_slide(current_direction * walkingSpeed * deltaSecs)
	_update_animation(current_direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if currentState == ENEMY_STATE.IDLE_MOVE:
		_on_idle_move(delta)
