extends Node2D

const AreaUtils = preload("../AreaUtils.gd")

onready var hatch_area = $Area2D

func _ready():
	assert(hatch_area != null && "You have to add a proper Area2D describing the extensions of the hatch!")

func _process(delta):
	var nodes = AreaUtils.get_nodes_of_group_in_area(hatch_area, "hatchable")
	for node in nodes:
		node.on_on_hatch()
