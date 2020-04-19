extends Node2D

var hatched = false
var character

func _ready():
	character = get_parent()
	assert(character.has_method("on_on_hatch") && "add a on_on_hatch function in parent object")
	pass


func on_on_hatch():
	character.on_on_hatch()
