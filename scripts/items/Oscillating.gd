extends Node2D

export(float) var width = 10.0
export(float) var interval_sec = 1.0

onready var init_position = position

var angle = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle += 2 * PI * delta / interval_sec
	position.y = init_position.y + sin(angle) * width
	
