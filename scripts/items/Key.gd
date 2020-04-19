extends Node2D

signal destroyed

func _ready():
	pass # Replace with function body.

func consume():
	emit_signal("destroyed")

func _process(delta):
	pass
