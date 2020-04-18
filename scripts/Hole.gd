extends Node2D

const AreaUtils = preload("AreaUtils.gd")

onready var hole_area = $Area2D

signal fall

func _ready():
	assert(hole_area != null && "You have to add a proper Area2D describing the extensions of the hole!")


func _process(delta):
	var nodes = AreaUtils.get_nodes_of_group_in_area(hole_area, "fallable")
	for node in nodes:
		connect("fall", node, "on_hole_fall")
		emit_signal("fall")
