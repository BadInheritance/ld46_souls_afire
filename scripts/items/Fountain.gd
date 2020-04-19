extends Node

const AreaUtils = preload("res://scripts/AreaUtils.gd")

var closed = true
onready var fountain_area = $Area2D

func _ready():
	assert(fountain_area != null && "You have to add a proper Area2D describing the extensions of the fountain!")


func _process(_delta):
	if Input.is_action_just_pressed("player_action"):
		var nodes = AreaUtils.get_nodes_of_group_in_area(fountain_area, "fountain_activator")
		for node in nodes:
			node.on_fountain_activation()

