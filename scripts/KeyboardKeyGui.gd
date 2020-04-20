extends Control

export(SpriteFrames) var animatedSprite = null
# export (String, FILE, "*.tscn") var level_scene_path = "res://scenes/player_and_enemy.tscn"
export(int) var scancode = 0

var sprite = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = find_node("AnimatedSprite")
	sprite.frames = animatedSprite
	pass # Replace with function body.


func _process(delta):
	if Input.is_key_pressed(scancode):
		sprite.animation = 'pressed'
	else:
		sprite.animation = 'unpressed'
	pass
