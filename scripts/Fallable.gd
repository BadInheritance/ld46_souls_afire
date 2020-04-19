extends Node2D

var fallen = false
var character = null


func _ready():
	character = get_parent()
	assert(character.has_method("on_on_hole") && "add a on_on_hole function in parent object")
	pass


func on_on_hole():
	character.on_on_hole()
