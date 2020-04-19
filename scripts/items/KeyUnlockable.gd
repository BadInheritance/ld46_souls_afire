extends Node2D

const AreaUtils = preload("../AreaUtils.gd")

signal unlocked

onready var unloackable_area = $Area2D

func _ready():
	assert(unloackable_area != null && "You have to add a proper Area2D describing the extensions of the unloackable!")

func _process(_delta):
	var nodes = AreaUtils.get_nodes_of_group_in_area(unloackable_area, "key")
	for node in nodes:
		print("emit unlocked")
		emit_signal('unlocked')
		node.get_parent().remove_child(node)
