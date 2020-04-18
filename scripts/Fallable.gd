extends Node2D

signal fall_die

var falling = false
var character = null

func _ready():
	character = get_parent()
	connect("fall_die", character, "on_die")
	pass # Replace with function body.


func on_hole_fall():
	if !falling:
		emit_signal("fall_die")
	falling = true

