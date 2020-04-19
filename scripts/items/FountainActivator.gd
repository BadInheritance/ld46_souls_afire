extends Node2D

var character

func _ready():
	character = get_parent()
	assert(character.has_method("on_fountain_activation") && "add a on_fountain_activation function in parent object")
	pass


func on_fountain_activation():
	print('on_fountain_activation')
	character.on_fountain_activation()
