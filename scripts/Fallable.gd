extends Node2D

signal fall_die

var fallen = false
var character_jumping = false
var character = null

func on_jump_start():
	character_jumping = true

func on_jump_end():
	character_jumping = false

func _ready():
	character = get_parent()
	connect("fall_die", character, "on_die")
	character.connect("player_jump_start", self, "on_jump_start")
	character.connect("player_jump_end", self, "on_jump_end")
	pass # Replace with function body.


func on_on_hole():
	if !fallen && !character_jumping:
		emit_signal("fall_die")
	fallen = true

