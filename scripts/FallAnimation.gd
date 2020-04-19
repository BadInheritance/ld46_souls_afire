extends Node2D

var up_animation_time = 0.1
var down_animation_time = 0.2
var up_target = Vector2(0, -10)
var down_target = Vector2(0, 5)
onready var parent = get_parent()
var parent_initial_position

signal fall_animation_completed


func _ready():
	print("start up timer")
	$up_timer.start(up_animation_time)
	$up_timer.connect("timeout", self, "_on_up_animation_completed")
	$down_timer.connect("timeout", self, "_on_down_animation_completed")

	parent_initial_position = parent.position


func _on_up_animation_completed():
	print("start down timer")
	$down_timer.start(down_animation_time)


func _on_down_animation_completed():
	print("_on_down_animation_completed")
	parent.visible = false
	emit_signal("fall_animation_completed")


func _process(_delta):
	if ! $up_timer.is_stopped():
		var up_animation_fraction = (up_animation_time - $up_timer.time_left) / up_animation_time
		parent.position = parent_initial_position + up_target * up_animation_fraction
	if ! $down_timer.is_stopped():
		var down_animation_fraction = (
			(down_animation_time - $down_timer.time_left)
			/ down_animation_time
		)
		parent.position = parent_initial_position + up_target +  down_target * down_animation_fraction
		parent.scale *= 0.9
