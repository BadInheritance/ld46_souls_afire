extends Node


var closed = true
export var locked = false

onready var sprite = $AnimatedSprite
onready var door_area = $Area2D
onready var door_body_shape = $door_body/door_body_shape

func _is_player_close() -> bool:
	var areas = door_area.get_overlapping_areas()
	for area in areas:
		var parent = area.get_parent()
		if parent.is_in_group("door_opener"):
			return true
	return false

func _lock():
	locked = true

func _unlock():
	print("door unlocked")
	locked = false

func _open():
	sprite.animation = 'open'
	door_body_shape.disabled = true
	closed = false

func _close():
	sprite.animation = 'close'
	door_body_shape.disabled = false
	closed = true

func _toggle():
	if closed && !locked:
		_open()
	else:
		_close()

func _ready():
	var key_unlockable = find_node("KeyUnlockable", true, false)
	print("key unlockable" + str(key_unlockable))
	if(key_unlockable != null):
		key_unlockable.connect("unlocked", self, "_unlock")

	if closed:
		_close()
	else:
		_open()
	pass

func _process(_delta):
	var door_action = Input.is_action_just_pressed("player_action")
	var player_is_close = _is_player_close()
	if door_action && player_is_close:
		_toggle()

