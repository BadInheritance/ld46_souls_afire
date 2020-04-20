extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "default"

func _on_candle_die():
	$AnimatedSprite.animation = "burnt"
