extends Control

export(Resource) var animatedSprite = null
# export (String, FILE, "*.tscn") var level_scene_path = "res://scenes/player_and_enemy.tscn"
export(int) var scancode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.frames = animatedSprite
	pass # Replace with function body.


func _process(delta):
	if Input.is_key_pressed(scancode):
		$AnimatedSprite.animation = 'pressed'
	else:
		$AnimatedSprite.animation = 'unpressed'
	pass
